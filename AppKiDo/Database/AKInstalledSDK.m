//
//  AKInstalledSDK.m
//  AppKiDo
//
//  Created by Andy Lee on 6/3/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKInstalledSDK.h"
#import "DIGSLog.h"
#import "NSFileManager+AppKiDo.h"

@interface AKInstalledSDK ()
@property (strong, readonly) NSDictionary *sdkPlist;
- (instancetype)initWithBasePath:(NSString *)sdkBasePath NS_DESIGNATED_INITIALIZER;
@end

@implementation AKInstalledSDK

#pragma mark - Finding installed SDKs

+ (NSArray *)sdksWithinXcodePath:(NSString *)xcodeAppPath
{
	NSParameterAssert(xcodeAppPath != nil);
	NSMutableArray *sdks = [NSMutableArray array];

	for (NSString *sdkBasePath in [self _sdkBasePathsWithinXcodePath:xcodeAppPath]) {
		[sdks addObject:[[AKInstalledSDK alloc] initWithBasePath:sdkBasePath]];
	}

	SEL finderLikeCompare = @selector(localizedStandardCompare:);
	[sdks sortUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"platform"
																ascending:YES
																 selector:finderLikeCompare],
								  [NSSortDescriptor sortDescriptorWithKey:@"version"
																ascending:YES
																 selector:finderLikeCompare] ]];
	return sdks;
}

#pragma mark - Init/awake/dealloc

- (instancetype)initWithBasePath:(NSString *)sdkBasePath
{
	NSParameterAssert(sdkBasePath != nil);
	self = [super init];
	if (self) {
		_basePath = sdkBasePath;

		NSString *settingsFilePath = [sdkBasePath stringByAppendingPathComponent:@"SDKSettings.plist"];
		_sdkPlist = [NSDictionary dictionaryWithContentsOfFile:settingsFilePath];
		if (_sdkPlist == nil) {
			QLog(@"+++ [ERROR] Could not load plist from %@", settingsFilePath);
			return nil;
		}
	}
	return self;
}

- (instancetype)init
{
	return [self initWithBasePath:nil];
}

#pragma mark - Getters and setters

- (NSString *)platform
{
	NSDictionary *defaultProperties = self.sdkPlist[@"DefaultProperties"];
	return defaultProperties[@"PLATFORM_NAME"];
}

- (NSString *)version
{
	return self.sdkPlist[@"Version"];
}

- (NSString *)displayName
{
	return self.sdkPlist[@"DisplayName"];
}

#pragma mark - NSObject methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p name='%@' platform='%@' version='%@'>",
			self.className, self,
			self.displayName, self.platform, self.version];
}

#pragma mark - Private methods

+ (NSArray *)_sdkBasePathsWithinXcodePath:(NSString *)xcodeAppPath
{
	NSParameterAssert(xcodeAppPath != nil);
	NSMutableArray *sdkBasePaths = [NSMutableArray array];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;

	for (NSString *platformPath in [self _platformPathsWithinXcodePath:xcodeAppPath]) {
		// Search for .sdk directories that are not symlinks.
		NSString *sdksContainerPath = [platformPath stringByAppendingPathComponent:@"Developer/SDKs"];
		NSArray *itemsInSDKsContainer = [fm contentsOfDirectoryAtPath:sdksContainerPath error:&error];
		if (itemsInSDKsContainer == nil) {
			QLog(@"+++ [ERROR] %s Could not get contents of directory '%@' -- %@", __PRETTY_FUNCTION__, sdksContainerPath, error);
			return nil;
		}

		for (NSString *sdkItem in itemsInSDKsContainer) {
			if (![sdkItem hasSuffix:@".sdk"]) {
				continue;
			}

			NSString *sdkPath = [sdksContainerPath stringByAppendingPathComponent:sdkItem];
			if ([fm ak_isSymlink:sdkPath]) {
				continue;
			}

			[sdkBasePaths addObject:sdkPath];
		}
	}

	return sdkBasePaths;
}

+ (NSArray *)_platformPathsWithinXcodePath:(NSString *)xcodeAppPath
{
	NSParameterAssert(xcodeAppPath != nil);
	NSMutableArray *platformPaths = [NSMutableArray array];
	NSString *platformsContainerPath = [xcodeAppPath stringByAppendingPathComponent:@"Contents/Developer/Platforms"];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;

	// Search for .platform directories.  Exclude those that are symlinks or
	// have the form XYZSimulator.platorm.
	NSArray *itemsInPlatformsContainer = [fm contentsOfDirectoryAtPath:platformsContainerPath error:&error];
	if (itemsInPlatformsContainer == nil) {
		QLog(@"+++ [ERROR] %s Could not get contents of directory '%@' -- %@", __PRETTY_FUNCTION__, platformsContainerPath, error);
		return nil;
	}
	for (NSString *platformItem in itemsInPlatformsContainer) {
		if ([platformItem hasSuffix:@"Simulator.platform"]) {
			continue;
		}

		if (![platformItem hasSuffix:@".platform"]) {
			continue;
		}

		NSString *platformPath = [platformsContainerPath stringByAppendingPathComponent:platformItem];
		if ([fm ak_isSymlink:platformPath]) {
			continue;
		}

		[platformPaths addObject:platformPath];
	}

	return platformPaths;
}

@end
