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
@property (strong) NSMutableArray<NSString *> *frameworkNamesInternal;
@property (strong) NSMutableArray<AKClassDeclarationInfo *> *classDeclarationsInternal;
@property (strong) NSMutableSet *classNamesWithKnownSuperclass;
@property (strong) NSMutableSet *classNamesPendingDeclaredSuperclass;
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

#pragma mark - Getters and setters

- (NSArray *)frameworkNames
{
	if (self.frameworkNamesInternal == nil) {
		[self _lazyInit];
	}
	return [self.frameworkNamesInternal copy];
}

- (NSArray<AKClassDeclarationInfo *> *)classDeclarations
{
	if (self.classDeclarationsInternal == nil) {
		[self _lazyInit];
	}
	return [self.classDeclarationsInternal copy];
}

#pragma mark - Private methods

// Constructs the frameworkNamesInternal and classDeclarationsInternal arrays by
// scanning the SDK's framework directories.
- (void)_lazyInit
{
	// Initialize the array properties we will be populating.
	self.frameworkNamesInternal = [[NSMutableArray alloc] init];
	self.classDeclarationsInternal = [[NSMutableArray alloc] init];

	// Initialize arrays we will use for temporary storage.
	self.classNamesWithKnownSuperclass = [NSMutableSet setWithObjects:@"NSObject", @"NSProxy", nil];
	self.classNamesPendingDeclaredSuperclass = [[NSMutableSet alloc] init];

	// Find the SDK's framework directories, and scan the .h files within them.
	[self _scanSDKHeaders];

	// KLUDGE: Some classes, at least in the macOS 10.11.4 docset, are declared
	// in header files that don't live in the SDK directory.
	if ([self.installedSDK.platformInternalName isEqualToString:AKPlatformInternalNameMac]) {
		[self _scanITunesLibraryHeaders];
		[self _scanFxPlugHeaders];
	}

	// The array self.classDeclarationsInternal now contains information about
	// all the class:superclass declarations we found.  The problem is that some
	// header files contain two declarations of the same class, separated by
	// "#if TARGET_OS_PHONE".  This means we may have duplicate, possibly
	// conflicting class declarations in our list.
	//
	// To avoid this, one option would have been to do more sophisticated
	// parsing of the header files, and select the appropriate class declaration
	// by mimicking what the compiler would do -- essentially, by evaluating the
	// TARGET_OS_PHONE macro and ignoring whichever class declaration is in the
	// branch I don't want.
	//
	// I'm taking a simpler approach, which is first to collect *all* the class
	// declarations, including the possible duplicates, and then discard any for
	// which I can't trace ancestry back to one of the two root classes.  I
	// *think* this works.
	while (YES) {
		NSInteger numPruned = [self _pruneClassDeclarationsAndReturnNumberPruned];
		QLog(@"+++ Pruned %zd class declarations.", numPruned);
		if (numPruned == 0) {
			break;
		}
	}

	// Clear out the temporary arrays.
	self.classNamesWithKnownSuperclass = nil;
	self.classNamesPendingDeclaredSuperclass = nil;
}

- (NSInteger)_pruneClassDeclarationsAndReturnNumberPruned
{
	NSInteger numPruned = 0;

	NSMutableArray *declarationsToKeep = [[NSMutableArray alloc] init];
	for (AKClassDeclarationInfo *classInfo in self.classDeclarationsInternal) {
		if ([self.classNamesWithKnownSuperclass containsObject:classInfo.nameOfSuperclass]) {
			[declarationsToKeep addObject:classInfo];
		}
	}
	self.classDeclarationsInternal = declarationsToKeep;

	return numPruned;
}

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
		// We're only interested in item names of the form "X.framework".
		if (![fwItem hasSuffix:@".framework"]) {
			continue;
		}

		// Make note of the framework name.
		NSString *frameworkName = [fwItem.lastPathComponent stringByDeletingPathExtension];
		[self.frameworkNamesInternal addObject:frameworkName];

		// Scan all .h files within this framework.
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

- (void)_scanFxPlugHeaders  //TODO: Either fill this in or decide not to.
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

		[self.classNamesWithKnownSuperclass addObject:subclassName];
		[self.classNamesPendingDeclaredSuperclass removeObject:subclassName];

		if (![self.classNamesWithKnownSuperclass containsObject:superclassName]) {
			[self.classNamesPendingDeclaredSuperclass addObject:superclassName];
		}

		AKClassDeclarationInfo *classInfo = [[AKClassDeclarationInfo alloc] init];
		classInfo.nameOfClass = subclassName;
		classInfo.nameOfSuperclass = superclassName;
		classInfo.frameworkName = frameworkName;
		classInfo.headerPath = (isSDKBasePath ? relativePath : filePath);
		classInfo.headerPathIsRelativeToSDK = isSDKBasePath;
		[self.classDeclarationsInternal addObject:classInfo];
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
