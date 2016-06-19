//
//  DocSetIndex.m
//  AppKiDo
//
//  Created by Andy Lee on 4/17/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "DocSetIndex.h"
#import "AKPlatformConstants.h"
#import "AKSortUtils.h"
#import "DIGSLog.h"

@interface DocSetIndex ()
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong) NSDictionary *infoPlist;
@end

@implementation DocSetIndex

// We need to explicitly synthesize these because we provide custom getter methods.
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

#pragma mark - Finding installed docsets

+ (NSArray *)installedDocSets
{
	NSMutableArray *docSets = [NSMutableArray array];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	NSString *docSetsContainerPath = [@"~/Library/Developer/Shared/Documentation/DocSets"
									  stringByExpandingTildeInPath];
	NSArray *dirContents = [fm contentsOfDirectoryAtPath:docSetsContainerPath error:&error];

	if (dirContents == nil) {
		QLog(@"+++ [ERROR] Failed to get contents of '%@' -- %@", docSetsContainerPath, error);
		return nil;
	}

	for (NSString *itemName in dirContents) {
		if ([itemName.pathExtension isEqualToString:@"docset"]) {
			NSString *docSetPath = [docSetsContainerPath stringByAppendingPathComponent:itemName];
			DocSetIndex *docSetIndex = [[DocSetIndex alloc] initWithDocSetPath:docSetPath];
			NSArray *suffixesForSDKDocSets = @[ @".documentation.OSX",
												@".documentation.iOS",
												@".documentation.watchOS",
												@".documentation.tvOS",

												// Older:
												@".CoreReference",
												@".iOSLibrary" ];
			for (NSString *suffix in suffixesForSDKDocSets) {
				if ([docSetIndex.bundleIdentifier hasSuffix:suffix]) {
					[docSets addObject:docSetIndex];
					break;
				}
			}
		}
	}

	[docSets sortUsingDescriptors:@[AKFinderLikeSort(@"platformInternalName"),
									AKFinderLikeSort(@"platformVersion")]];
	return docSets;
}

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDocSetPath:(NSString *)docSetPath
{
	NSParameterAssert(docSetPath != nil);
	self = [super init];
	if (self) {
		_docSetPath = docSetPath;

		NSString *plistPath = [docSetPath stringByAppendingPathComponent:@"Contents/Info.plist"];
		_infoPlist = [NSDictionary dictionaryWithContentsOfFile:plistPath];

		NSAssert(_infoPlist != nil, @"Could not load Info.plist in %@", docSetPath);
	}
	return self;
}

- (instancetype)init
{
	return [self initWithDocSetPath:nil];
}

#pragma mark - Getters and setters

- (NSString *)docSetInternalName
{
	return self.infoPlist[(NSString *)kCFBundleNameKey];
}

- (NSString *)docSetDisplayName
{
	return [NSString stringWithFormat:@"%@ %@", self.platformDisplayName, self.platformVersion];
}

- (NSString *)bundleIdentifier
{
	return self.infoPlist[(NSString *)kCFBundleIdentifierKey];
}

- (NSString *)platformInternalName
{
	return self.infoPlist[@"DocSetPlatformFamily"];
}

- (NSString *)platformDisplayName
{
	return AKDisplayNameForPlatformInternalName(self.platformInternalName);
}

- (NSString *)platformVersion
{
	return self.infoPlist[@"DocSetPlatformVersion"];
}

- (NSManagedObjectModel *)managedObjectModel
{
	// Lazy loading.
	if (_managedObjectModel) {
		return _managedObjectModel;
	}

//	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DocSetModel" withExtension:@"momd"];
//	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	NSString *pathToMOMFile = [self.docSetPath stringByAppendingPathComponent:@"Contents/Resources/docSet.mom"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:pathToMOMFile]];

	for (NSEntityDescription *entity in _managedObjectModel.entities) {
		if ([entity.managedObjectClassName isEqualToString:@"NSManagedObject"]) {
			if (NSClassFromString(entity.name)) {
				QLog(@"+++ Changing MO class for entity %@ to %@", entity.managedObjectClassName, entity.name);
				entity.managedObjectClassName = nil;
			} else {
				QLog(@"+++ There is no class %@, will stick with %@", entity.name, entity.managedObjectClassName);
			}
		}
	}

	return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	// Lazy loading.
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
	// Lazy loading.
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

- (NSURL *)documentsBaseURL  //TODO: Handle the case when we need the fallback (online) URL.
{
	NSString *documentsPath = [self.docSetPath stringByAppendingPathComponent:@"Contents/Resources/Documents"];
	return [NSURL fileURLWithPath:documentsPath];
}

#pragma mark - NSObject methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p name='%@' platform='%@' version='%@'>",
			self.className, self,
			self.docSetInternalName, self.platformInternalName, self.platformVersion];
}

@end
