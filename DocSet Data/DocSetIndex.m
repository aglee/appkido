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
@property (strong) NSDictionary *infoPlist;
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

- (NSString *)docSetName
{
	return self.infoPlist[(NSString *)kCFBundleNameKey];
}

- (NSString *)bundleIdentifier
{
	return self.infoPlist[(NSString *)kCFBundleIdentifierKey];
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

- (NSURL *)documentsBaseURL  //TODO: Handle the case when we need the fallback URL.
{
	NSString *documentsPath = [self.docSetPath stringByAppendingPathComponent:@"Contents/Resources/Documents"];
	return [NSURL fileURLWithPath:documentsPath];
}

- (NSURL *)headerFilesBaseURL
{
	NSString *sdkPath = @"/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk";  //TODO: Get the right path.
	return [NSURL fileURLWithPath:sdkPath];
}

#pragma mark - NSObject methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %@>", self.className, self.docSetName];
}

@end
