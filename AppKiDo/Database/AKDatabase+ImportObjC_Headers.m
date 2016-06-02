//
//  AKDatabase+ImportObjC_Headers.m
//  AppKiDo
//
//  Created by Andy Lee on 6/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase+Private.h"
#import "AKClassToken.h"
#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"
#import "AKProtocolToken.h"
#import "AKRegexUtils.h"
#import "AKResult.h"
#import "DIGSLog.h"
#import "NSArray+AppKiDo.h"

@implementation AKDatabase (ImportObjC_Headers)

- (void)_scanFrameworkHeaderFilesForClassDeclarations
{
	// Iterate over every XXX.framework directory under <SDK>/System/Library/Frameworks.
	static NSString *s_frameworksRelativeBasePath = @"System/Library/Frameworks";
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *frameworksBasePath = [self.sdkBasePath stringByAppendingPathComponent:s_frameworksRelativeBasePath];

	for (NSString *fwItem in [fm subpathsAtPath:frameworksBasePath]) {
		if (![fwItem hasSuffix:@".framework"]) {
			continue;
		}

		// Scan all .h files within this framework.
		NSString *frameworkName = [fwItem stringByDeletingPathExtension];
		NSString *frameworkDirPath = [frameworksBasePath stringByAppendingPathComponent:fwItem];
		for (NSString *itemInsideFramework in [fm enumeratorAtPath:frameworkDirPath]) {
			if (![itemInsideFramework hasSuffix:@".h"]) {
				continue;
			}

			// relativeHeaderPath has to be relative to the SDK base path.
			NSString *relativeHeaderPath = [[s_frameworksRelativeBasePath
											 stringByAppendingPathComponent:fwItem]
											stringByAppendingPathComponent:itemInsideFramework];
			[self _scanHeaderFileWithRelativePath:relativeHeaderPath frameworkName:frameworkName];
		}
	}
}

- (void)_scanHeaderFileWithRelativePath:(NSString *)relativePath
						  frameworkName:(NSString *)frameworkName
{
	// Load the header file into a string.  I'm using NSISOLatin1StringEncoding
	// because NSUTF8StringEncoding doesn't work for all files.  Example:
	// Transform.h in vImage.framework under MacOSX10.11.sdk.
	NSString *filePath = [self.sdkBasePath stringByAppendingPathComponent:relativePath];
	NSError *error;
	NSString *headerString = [NSString stringWithContentsOfFile:filePath
													   encoding:NSISOLatin1StringEncoding
														  error:&error];
	if (headerString == nil) {
		QLog(@"[ERROR] File [%@], error %@.", filePath, error);
		return;
	}

	// Search the string for class declarations.
	NSArray *matches = [[self _classDeclarationRegex] matchesInString:headerString
															  options:0
																range:NSMakeRange(0, headerString.length)];
	for (NSTextCheckingResult *match in matches) {
		// Set up a token for the subclass.
		NSString *subclassName = [headerString substringWithRange:[match rangeAtIndex:1]];
		AKClassToken *subclassToken = [self _getOrAddClassTokenWithName:subclassName];
		subclassToken.frameworkName = frameworkName;

		// Set up a token for the superclass.
		NSString *superclassName = [headerString substringWithRange:[match rangeAtIndex:2]];
		AKClassToken *superclassToken = [self _getOrAddClassTokenWithName:superclassName];
		[superclassToken addChildClass:subclassToken];
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
