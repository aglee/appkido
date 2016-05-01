//
//  DocSetIndex.m
//  AppKiDo
//
//  Created by Andy Lee on 4/17/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "DocSetIndex.h"
#import "QuietLog.h"
#import "DocSetQuery.h"

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
    NSParameterAssert(docSetPath != nil);
	self = [super init];
	if (self) {
		_docSetPath = docSetPath;  //TODO: Fail if doesn't look like a docset bundle.
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
	NSError *error = nil;
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

#pragma mark - Queries

- (DocSetQuery *)queryWithEntityName:(NSString *)entityName
{
    return [DocSetQuery queryWithDocSetIndex:self entityName:entityName];
}

- (NSURL *)documentationURLForObject:(id)obj
{
	if ([obj isKindOfClass:[DSAToken class]]) {
		return [self _documentationURLForToken:(DSAToken *)obj];
	} else if ([obj isKindOfClass:[DSANodeURL class]]) {
		return [self _documentationURLForNodeURL:(DSANodeURL *)obj];
	}

	return nil;
}

#pragma mark - Private methods

- (NSString *)_documentsDirPath
{
	return [self.docSetPath stringByAppendingPathComponent:@"Contents/Resources/Documents"];
}

- (NSURL *)_documentationURLForToken:(DSAToken *)token
{
	NSString *pathString = [self _documentsDirPath];
	pathString = [pathString stringByAppendingPathComponent:token.metainformation.file.path];
	NSURL *url = [NSURL fileURLWithPath:pathString];
	if (token.metainformation.anchor) {
		NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
		urlComponents.fragment = token.metainformation.anchor;
		url = [urlComponents URL];
	}

	return url;
}

- (NSURL *)_documentationURLForNodeURL:(DSANodeURL *)nodeURLInfo
{
	NSString *pathString = [self _documentsDirPath];  //TODO: Handle fallback to online URL if local docset has not been installed.
	pathString = [pathString stringByAppendingPathComponent:nodeURLInfo.path];
	NSURL *url = [NSURL fileURLWithPath:pathString];;
	if (nodeURLInfo.anchor) {
		NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
		urlComponents.fragment = nodeURLInfo.anchor;
		url = [urlComponents URL];
	}

	return url;
}

@end
