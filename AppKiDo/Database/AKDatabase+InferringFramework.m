//
//  AKDatabase+InferringFramework.m
//  AppKiDo
//
//  Created by Andy Lee on 6/29/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase+Private.h"
#import "AKRegexUtils.h"
#import "AKResult.h"
#import "AKTopicConstants.h"
#import "DIGSLog.h"
#import "DocSetModel.h"
#import "NSString+AppKiDo.h"

//TODO: See if I need to translate "ApplicationKit" to AppKit anywhere.

@implementation AKDatabase (InferringFramework)

- (AKFramework *)_frameworkForTokenMO:(DSAToken *)tokenMO
{
	NSString *frameworkName = [self _frameworkNameForTokenMO:tokenMO];

	//KLUDGE: Fictitious framework for tokens where I haven't figured out a way
	// to infer their real framework.
	if (frameworkName == nil) {
		frameworkName = @"ZZFrameworkUnknown";
	}

	return [self _getOrAddFrameworkWithName:frameworkName];
}

- (NSString *)_frameworkNameForTokenMO:(DSAToken *)tokenMO
{
	return ([self _frameworkNameExplicitlyDeclaredForTokenMO:tokenMO]
			?: [self _frameworkNameInferredFromHeaderPathOfTokenMO:tokenMO]
			?: [self _frameworkNameInferredFromDocPathOfTokenMO:tokenMO]
			?: [self _frameworkNameInferredFromParentNodeNameOfTokenMO:tokenMO]);
}

- (NSString *)_frameworkNameExplicitlyDeclaredForTokenMO:(DSAToken *)tokenMO
{
	return tokenMO.metainformation.declaredIn.frameworkName;
}

- (NSString *)_frameworkNameInferredFromHeaderPathOfTokenMO:(DSAToken *)tokenMO
{
	NSString *headerPath = tokenMO.metainformation.declaredIn.headerPath;
	if (headerPath == nil) {
		return nil;
	}

	NSString *frameworkName;

	// Does the header path contain "SOMETHING.framework"?
	if (frameworkName == nil) {
		static NSRegularExpression *s_headerPathRegex;
		static dispatch_once_t once;
		dispatch_once(&once,^{
			NSString *pattern = @".*/(%ident%)\\.framework/.*";
			s_headerPathRegex = [AKRegexUtils constructRegexWithPattern:pattern].object;
		});

		NSDictionary *captureGroups = [AKRegexUtils matchRegex:s_headerPathRegex
												toEntireString:headerPath].object;
		frameworkName = captureGroups[@1];
	}

	// Is this the special case of NSObject?  NSObject, and by extension all its
	// members, got moved out of Foundation into the Objective-C runtime.
	if (frameworkName == nil) {
		if ([headerPath ak_contains:@"usr/include/objc"]) {
			frameworkName = @"Objective-C Runtime";
		}
	}

	if (frameworkName) {
		//QLog(@"+++ Got framework name '%@' for '%@' from the header path.", frameworkName, tokenMO.tokenName);
	}
	return frameworkName;
}

- (NSString *)_frameworkNameInferredFromDocPathOfTokenMO:(DSAToken *)tokenMO
{
	NSString *docPath = tokenMO.metainformation.file.path;
	if (docPath == nil) {
		return nil;
	}

	NSString *frameworkName;
	for (NSString *pathComponent in docPath.pathComponents) {
		// Is pathComponent the name of a framework we already know about?
		if ([self frameworkWithName:pathComponent]) {
			frameworkName = pathComponent;
			break;
		}

		// Does pathComponent have the form "SOMETHING_Framework"?
		NSArray *splitByUnderscore = [pathComponent componentsSeparatedByString:@"_"];
		if (splitByUnderscore.count == 2 && [splitByUnderscore[1] isEqualToString:@"Framework"]) {
			frameworkName = splitByUnderscore[0];
			break;
		}
	}
	
	if (frameworkName) {
		//QLog(@"+++ Got framework name '%@' for '%@' from the doc path.", frameworkName, tokenMO.tokenName);
	}
	return frameworkName;
}

// Does the node name have the form "SOMETHING Framework Reference"?  SOMETHING
// will often be an exact framework name (e.g. "GameKit Framework Reference").
// It might also be a framework name that's been expanded to a phrase (e.g.
// "Core Video Framework Reference"), and it might contain characters that need
// to be stripped (e.g. "Model I/O Framework Reference").
- (NSString *)_frameworkNameInferredFromParentNodeNameOfTokenMO:(DSAToken *)tokenMO
{
	NSString *nodeName = tokenMO.parentNode.kName;
	NSMutableArray *words = [[nodeName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
	[words removeObject:@""];  // In case there are double spaces in the original string.

	// Trim the words "Framework Reference" from the end.
	if (![words.lastObject isEqualToString:@"Reference"]) {
		return nil;
	}
	[words removeLastObject];

	if (![words.lastObject isEqualToString:@"Framework"]) {
		return nil;
	}
	[words removeLastObject];

	if (words.count == 0) {
		return nil;
	}

	// Glom the remaining words together and remove non-alphanumeric characters.
	NSString *frameworkName = [[[words componentsJoinedByString:@""] componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
	QLog(@"+++ Got framework name '%@' for '%@' (type '%@') from the node name '%@'.", frameworkName, tokenMO.tokenName, tokenMO.tokenType.typeName, nodeName);
	return frameworkName;
}

@end
