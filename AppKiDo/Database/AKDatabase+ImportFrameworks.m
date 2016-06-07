//
//  AKDatabase+ImportFrameworks.m
//  AppKiDo
//
//  Created by Andy Lee on 5/28/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKDatabase+Private.h"
#import "AKFramework.h"
#import "AKManagedObjectQuery.h"
#import "AKNamedObjectGroup.h"
#import "AKRegexUtils.h"
#import "AKResult.h"
#import "DIGSLog.h"
#import "NSString+AppKiDo.h"

@implementation AKDatabase (ImportFrameworks)

#pragma mark - Importing frameworks

- (void)_importFrameworks
{
	AKManagedObjectQuery *query = [self _queryWithEntityName:@"Header"];
	query.keyPaths = @[ @"frameworkName" ];
	query.predicateString = @"frameworkName != NULL";

	AKResult *result = [query fetchDistinctObjects];  //TODO: Handle error.
	if (result.error) {
		return;
	}

	NSArray *fetchedObjects = result.object;
	for (NSDictionary *dict in fetchedObjects) {
		(void)[self _frameworkWithNameAddIfAbsent:dict[@"frameworkName"]];
	}
}

#pragma mark - Inferring framework info

- (AKFramework *)_frameworkForTokenMOAddIfAbsent:(DSAToken *)tokenMO
{
	NSString *frameworkName = [self _frameworkNameForTokenMO:tokenMO];
	return [self _frameworkWithNameAddIfAbsent:frameworkName];
}

- (AKFramework *)_frameworkWithNameAddIfAbsent:(NSString *)frameworkName
{
	AKFramework *framework = [self frameworkWithName:frameworkName];
	if (framework == nil) {
		framework = [[AKFramework alloc] initWithName:frameworkName];
		[self.frameworksGroup addNamedObject:framework];
		QLog(@"+++ Added framework %@.", frameworkName);
	}
	return framework;
}

- (NSString *)_frameworkNameForTokenMO:(DSAToken *)tokenMO
{
	NSString *frameworkName;

	// Does the DocSetIndex say what the framework is?
	if (frameworkName == nil) {
		frameworkName = tokenMO.metainformation.declaredIn.frameworkName;
	}

	// Can we get the framework name from the headerPath?
	if (frameworkName == nil) {
		NSString *headerPath = tokenMO.metainformation.declaredIn.headerPath;
		frameworkName = [self _tryToInferFrameworkNameFromHeaderPath:headerPath];

		if (frameworkName) {
			QLog(@"+++ Got framework name '%@' for '%@' from the header path.", frameworkName, tokenMO.tokenName);
		}
	}

	// Can we get the framework name from the doc path?
	if (frameworkName == nil) {
		NSString *docPath = tokenMO.metainformation.file.path;
		frameworkName = [self _tryToInferFrameworkNameFromDocPath:docPath];

		if (frameworkName) {
			QLog(@"+++ Got framework name '%@' for '%@' from the doc path.", frameworkName, tokenMO.tokenName);
		}
	}

	//TODO: KLUDGE -- Fictitious framework for tokens where I haven't figured
	// out yet how to determine their real framework.
	if (frameworkName == nil) {
		frameworkName = @"<???>";
	}

	if (frameworkName == nil) {
		//QLog(@"+++ Could not infer framework name for tokenMO %@, type %@", tokenMO.tokenName, tokenMO.tokenType.typeName);  //TODO: Fix when this happens.
	}
	return frameworkName;
}

// Looks for a match with .../SomeFrameworkName.framework/...
- (NSRegularExpression *)_regexForFindingFrameworkNameInHeaderPath
{
	static NSRegularExpression *s_regex;
	static dispatch_once_t once;
	dispatch_once(&once,^{
		s_regex = [AKRegexUtils constructRegexWithPattern:@".*/(%ident%)\\.framework/.*"].object;
	});
	return s_regex;
}

- (NSString *)_tryToInferFrameworkNameFromHeaderPath:(NSString *)headerPath
{
	if (headerPath == nil) {
		return nil;
	}

	NSString *frameworkName;

	// Does the header path contain "SOMETHING.framework"?
	if (frameworkName == nil) {
		NSDictionary *captureGroups = [AKRegexUtils matchRegex:[self _regexForFindingFrameworkNameInHeaderPath] toEntireString:headerPath].object;
		frameworkName = captureGroups[@1];
	}

	// NSObject, and by extension all its members, got moved out of Foundation
	// into the Objective-C runtime.
	if (frameworkName == nil) {
		if ([headerPath ak_contains:@"usr/include/objc"]) {
			frameworkName = @"Objective-C Runtime";
		}
	}

	return frameworkName;
}

- (NSString *)_tryToInferFrameworkNameFromDocPath:(NSString *)docPath
{
	if (docPath == nil) {
		return nil;
	}

	for (NSString *pathComponent in docPath.pathComponents) {
		// Is pathComponent the name of an existing framework?
		if ([self frameworkWithName:pathComponent]) {
			return pathComponent;
		}

		// Does pathComponent have the form "SOMETHING_Framework"?
		NSArray *splitByUnderscore = [pathComponent componentsSeparatedByString:@"_"];
		if (splitByUnderscore.count == 2 && [splitByUnderscore[1] isEqualToString:@"Framework"]) {
			(void)[self _frameworkWithNameAddIfAbsent:splitByUnderscore[0]];
			return splitByUnderscore[0];
		}
	}

	return nil;
}

@end