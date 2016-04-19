//
//  DocSetIndex.m
//  AppKiDo
//
//  Created by Andy Lee on 4/17/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "DocSetIndex.h"
#import "QuietLog.h"

@interface DocSetIndex ()
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation DocSetIndex

// We need to explicitly synthesize these because we provide custom getter methods.
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDocSetPath:(NSString *)docSetPath
{
	self = [super init];
	if (self) {
		_docSetPath = docSetPath;
	}
	return self;
}

- (instancetype)init
{
	return [self initWithDocSetPath:nil];
}

#pragma mark - Getters and setters

- (NSManagedObjectModel *)managedObjectModel
{
	if (_managedObjectModel) {
		return _managedObjectModel;
	}

	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DocSetModel" withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

	return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (_persistentStoreCoordinator) {
		return _persistentStoreCoordinator;
	}

	NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
	NSString *pathToPersistentStoreFile = [self.docSetPath stringByAppendingPathComponent:@"Contents/Resources/docSet.dsidx"];
	NSURL *storeFileURL = [NSURL fileURLWithPath:pathToPersistentStoreFile];
	NSError *error;
	if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType
								   configuration:nil
											 URL:storeFileURL
										 options:@{ NSReadOnlyPersistentStoreOption: @YES }
										   error:&error]) {
		coordinator = nil;
	}
	_persistentStoreCoordinator = coordinator;

	if (error) {
		QLog(@"[%s] [ERROR] %@", __PRETTY_FUNCTION__, error);  //TODO: Throw an exception.
		return nil;
	}

	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
	if (_managedObjectContext) {
		return _managedObjectContext;
	}

	NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
	if (!coordinator) {
		return nil;
	}
	_managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	_managedObjectContext.persistentStoreCoordinator = coordinator;

	return _managedObjectContext;
}

#pragma mark - Fetch requests

- (NSArray *)fetchEntity:(NSString *)entityName sort:(NSArray *)sortSpecifiers predicateFormat:(NSString *)format va_args:(va_list)argList
{
	if (entityName == nil) {
		return nil;
	}

	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];

	// Was a predicate specified?
	if (format.length > 0) {
		fetchRequest.predicate = [NSPredicate predicateWithFormat:format arguments:argList];
	}

	// Was a sort order specified?
	if (sortSpecifiers.count > 0) {
		NSMutableArray *sortDescriptors = [NSMutableArray array];
		for (NSString *spec in sortSpecifiers) {
			NSString *errorMessage = nil;
			NSMutableArray *components = [[spec componentsSeparatedByString:@" "] mutableCopy];

			[components removeObject:@""];
			if (components.count == 0) {
				errorMessage = [NSString stringWithFormat:@"Sort specifier is empty."];
			} else {
				BOOL ascending = YES;

				if (components.count == 1) {
					ascending = YES;
				} else if (components.count == 2) {
					NSString *direction = [components[1] uppercaseString];

					if ([direction isEqualToString:@"ASC"]) {
						ascending = YES;
					} else if ([direction isEqualToString:@"DESC"]) {
						ascending = NO;
					} else {
						errorMessage = [NSString stringWithFormat:@"'%@' is not a valid sort direction.", direction];
					}
				} else {
					errorMessage = [NSString stringWithFormat:@"Too many terms in the sort specifier '%@'.", spec];
				}

				if (errorMessage) {
					QLog(@"[%s] [ERROR] %@", __PRETTY_FUNCTION__, errorMessage);  //TODO: Throw an exception.
					return nil;
				}

				[sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:components[0] ascending:ascending]];
			}
		}
		fetchRequest.sortDescriptors = sortDescriptors;
	}

	// Do the fetch.
//	fetchRequest.returnsObjectsAsFaults = NO;  //[agl] DEBUGGING
//	fetchRequest.fetchLimit = 50;  //[agl] DEBUGGING
	__block NSError *error;
	__block NSArray *fetchedObjects;
	[self.managedObjectContext performBlockAndWait:^{
		fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	}];
	if (fetchedObjects == nil) {
		QLog(@"[%s] [ERROR] %@", __PRETTY_FUNCTION__, error);  //TODO: Throw an exception.
		return nil;
	}
	return fetchedObjects;
}

- (NSArray *)fetchEntity:(NSString *)entityName sort:(NSArray *)sortSpecifiers where:(NSString *)format, ...
{
	va_list argList;
	va_start(argList, format);
	NSArray *fetchedObjects = [self fetchEntity:entityName sort:sortSpecifiers predicateFormat:format va_args:argList];
	va_end(argList);

	return fetchedObjects;
}

- (NSArray *)fetchDistinctAttributesWithName:(NSString *)attributeName ofEntity:(NSString *)entityName
{
    // Construct the fetch request.
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSEntityDescription *entityDescription = self.managedObjectModel.entitiesByName[entityName];

    fetchRequest.resultType = NSDictionaryResultType;
    fetchRequest.propertiesToFetch = @[entityDescription.propertiesByName[attributeName]];
    fetchRequest.returnsDistinctResults = YES;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K != NULL", attributeName];

    // Do the fetch.
    __block NSError *error;
    __block NSArray *fetchedObjects;
    [self.managedObjectContext performBlockAndWait:^{
        fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    if (fetchedObjects == nil) {
        QLog(@"[%s] [ERROR] %@", __PRETTY_FUNCTION__, error);  //TODO: Throw an exception.
        return nil;
    }

    return [fetchedObjects valueForKey:attributeName];
}

- (NSArray *)frameworkNames
{
    return [self fetchDistinctAttributesWithName:@"frameworkName" ofEntity:@"Header"];
}

@end
