//
//  AKHeaderScanner.m
//  AppKiDo
//
//  Created by Andy Lee on 6/2/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKHeaderScanner.h"
#import "AKClassDeclarationInfo.h"
#import "AKInstalledSDK.h"
#import "AKRegexUtils.h"
#import "AKResult.h"
#import "AKPlatformConstants.h"
#import "DIGSLog.h"

@interface AKHeaderScanner ()
@property (strong) AKInstalledSDK *installedSDK;
@property (strong) NSMutableArray *classDeclarations;  // Elements are dictionaries.
@property (strong) NSMutableSet *classNamesWithDeclaredSuperclass;
@property (strong) NSMutableSet *classNamesPENDINGDeclaredSuperclass;
@end

@implementation AKHeaderScanner

#pragma mark - Init/awake/dealloc

- (instancetype)initWithInstalledSDK:(AKInstalledSDK *)installedSDK
{
	NSParameterAssert(installedSDK != nil);
	self = [super init];
	if (self) {
		_installedSDK = installedSDK;
	}
	return self;
}

- (instancetype)init
{
	return [self initWithInstalledSDK:nil];
}

#pragma mark - Scanning header files

- (NSArray *)scanHeadersForClassDeclarations
{
	// Treat NSObject and NSProxy as having declared superclasses.  You could
	// say their superclasses have been "declared" to be nil.
	self.classDeclarations = [[NSMutableArray alloc] init];
	self.classNamesWithDeclaredSuperclass = [NSMutableSet setWithObjects:@"NSObject", @"NSProxy", nil];
	self.classNamesPENDINGDeclaredSuperclass = [[NSMutableSet alloc] init];

	[self _scanSDKHeaders];
	if ([self.installedSDK.platformInternalName isEqualToString:AKPlatformInternalNameMac]) {
		[self _scanITunesLibraryHeaders];
		[self _scanFxPlugHeaders];
	}

	// Return class declarations where the superclass is a class we have
	// previously seen declared as a subclass.  This should handle the cases
	// where a header contains two declarations for the same class, separated
	// by "#if TARGET_OS_IPHONE".  This should weed out whichever of the
	// declarations is the wrong one for this SDK.
	NSMutableArray *goodDeclarations = [[NSMutableArray alloc] init];
	for (AKClassDeclarationInfo *classInfo in self.classDeclarations) {
		if ([self.classNamesWithDeclaredSuperclass containsObject:classInfo.nameOfSuperclass]) {
			[goodDeclarations addObject:classInfo];
		}
	}
	return goodDeclarations;
}

#pragma mark - Private methods

- (void)_scanSDKHeaders
{
	// Iterate over every XXX.framework directory under <SDK>/System/Library/Frameworks.
	static NSString *s_frameworksRelativeBasePath = @"System/Library/Frameworks";
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	NSString *frameworksContainerPath = [self.installedSDK.basePath stringByAppendingPathComponent:s_frameworksRelativeBasePath];
	NSArray *itemsInFrameworksContainer = [fm contentsOfDirectoryAtPath:frameworksContainerPath error:&error];

	if (itemsInFrameworksContainer == nil) {
		QLog(@"+++ [ERROR] %s Could not get contents of directory '%@' -- %@", __PRETTY_FUNCTION__, frameworksContainerPath, error);
		return;
	}

	for (NSString *fwItem in itemsInFrameworksContainer) {
		if (![fwItem hasSuffix:@".framework"]) {
			continue;
		}

		// Scan all .h files within this framework.
		NSString *frameworkName = [fwItem.lastPathComponent stringByDeletingPathExtension];
		NSString *frameworkDirPath = [frameworksContainerPath stringByAppendingPathComponent:fwItem];
		for (NSString *itemInsideFramework in [fm enumeratorAtPath:frameworkDirPath]) {
			if (![itemInsideFramework hasSuffix:@".h"]) {
				continue;
			}

			// headerPathRelativeToSDK has to be relative to the SDK base path.
			NSString *headerPathRelativeToSDK = [[s_frameworksRelativeBasePath
												  stringByAppendingPathComponent:fwItem]
												 stringByAppendingPathComponent:itemInsideFramework];
			[self _scanHeaderFileAtRelativePath:headerPathRelativeToSDK
									   basePath:self.installedSDK.basePath
								  isSDKBasePath:YES
								  frameworkName:frameworkName];
		}
	}
}

- (void)_scanITunesLibraryHeaders
{
	NSString *frameworkDirPath = @"/Library/Frameworks/iTunesLibrary.framework";
	NSFileManager *fm = [NSFileManager defaultManager];
	for (NSString *itemInsideFramework in [fm enumeratorAtPath:frameworkDirPath]) {
		if (![itemInsideFramework hasSuffix:@".h"]) {
			continue;
		}

		[self _scanHeaderFileAtRelativePath:itemInsideFramework
								   basePath:frameworkDirPath
							  isSDKBasePath:NO
							  frameworkName:@"iTunesLibrary"];
	}
}

- (void)_scanFxPlugHeaders
{
}

// relativePath is relative to self.sdkBasePath.
- (void)_scanHeaderFileAtRelativePath:(NSString *)relativePath
							 basePath:(NSString *)basePath
						isSDKBasePath:(BOOL)isSDKBasePath
						frameworkName:(NSString *)frameworkName
{
	// Load the header file into a string.  I'm using NSISOLatin1StringEncoding
	// because NSUTF8StringEncoding doesn't work for all files.  Example:
	// Transform.h in vImage.framework under MacOSX10.11.sdk.
	NSString *filePath = [basePath stringByAppendingPathComponent:relativePath];
	NSError *error;
	NSString *fileContents = [NSString stringWithContentsOfFile:filePath
													   encoding:NSISOLatin1StringEncoding
														  error:&error];
	if (fileContents == nil) {
		QLog(@"[ERROR] File [%@], error %@.", filePath, error);
		return;
	}

	// Search the string for class declarations.
	NSArray *matches = [[self _classDeclarationRegex] matchesInString:fileContents
															  options:0
																range:NSMakeRange(0, fileContents.length)];
	for (NSTextCheckingResult *match in matches) {
		NSString *subclassName = [fileContents substringWithRange:[match rangeAtIndex:1]];
		NSString *superclassName = [fileContents substringWithRange:[match rangeAtIndex:2]];

		[self.classNamesWithDeclaredSuperclass addObject:subclassName];
		[self.classNamesPENDINGDeclaredSuperclass removeObject:subclassName];

		if (![self.classNamesWithDeclaredSuperclass containsObject:superclassName]) {
			[self.classNamesPENDINGDeclaredSuperclass addObject:superclassName];
		}

		AKClassDeclarationInfo *classInfo = [[AKClassDeclarationInfo alloc] init];
		classInfo.nameOfClass = subclassName;
		classInfo.nameOfSuperclass = superclassName;
		classInfo.frameworkName = frameworkName;
		classInfo.headerPath = (isSDKBasePath ? relativePath : filePath);
		classInfo.headerPathIsRelativeToSDK = isSDKBasePath;
		[self.classDeclarations addObject:classInfo];
	}
}

- (NSRegularExpression *)_classDeclarationRegex
{
	static NSRegularExpression *s_classDeclarationRegex;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		NSString *pattern = @"@interface (%ident%) : (%ident%)";
		AKResult *result = [AKRegexUtils constructRegexWithPattern:pattern];
		NSAssert(result.error == nil, @"Failed to construct class declaration regex: %@", result.error);
		s_classDeclarationRegex = result.object;
	});
	return s_classDeclarationRegex;
}

@end
