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
		NSString *frameworkName = dict[@"frameworkName"];
		AKFramework *framework = [[AKFramework alloc] initWithName:frameworkName];
		[self.frameworksGroup addNamedObject:framework];
	}
}

#pragma mark - Inferring framework info

- (AKFramework *)_frameworkForTokenMOAddIfAbsent:(DSAToken *)tokenMO
{
	NSString *frameworkName = [self _frameworkNameForTokenMO:tokenMO];
	if (frameworkName == nil) {
		return nil;
	}

	AKFramework *framework = [self frameworkWithName:frameworkName];
	if (framework == nil) {
		framework = [[AKFramework alloc] initWithName:frameworkName];
		[self.frameworksGroup addNamedObject:framework];
		QLog(@"+++ Added framework %@.", frameworkName);
	}
	return framework;
}

- (AKFramework *)_frameworkWithNameAddIfAbsent:(NSString *)frameworkName
{
	if (frameworkName == nil) {
		return nil;
	}

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
	// See if the DocSetIndex specifies a framework for this token.
	NSString *frameworkName = tokenMO.metainformation.declaredIn.frameworkName;
	if (frameworkName) {
		//QLog(@"+++ Framework %@ for %@ was explicit", frameworkName, self);
	}

	// See if we can infer the framework name from the headerPath.
	if (frameworkName == nil) {
		NSString *headerPath = tokenMO.metainformation.declaredIn.headerPath;
		frameworkName = [self _tryToInferFrameworkNameFromHeaderPath:headerPath];
	}

	// Try to infer framework name from doc path and maybe doc file name.
	if (frameworkName == nil) {
		NSString *docPath = tokenMO.metainformation.file.path;
		frameworkName = [self _tryToInferFrameworkNameFromDocPath:docPath];
	}

	//TODO: KLUDGE -- Hard-code a fictitious "Unknown Framework" for protocols
	// where I haven't figured out yet how to determine their real framework.
	if (frameworkName == nil && [tokenMO.tokenType.typeName isEqualToString:@"intf"]) {
		frameworkName = @"<???>";
	}

	if (frameworkName == nil) {
		//QLog(@"+++ Could not infer framework name for tokenMO %@, type %@", tokenMO.tokenName, tokenMO.tokenType.typeName);  //TODO: Fix when this happens.
	}
	return frameworkName;
}

//TODO: Remember that Swift tokens have the framework name *as* the declaredIn.headerPath value.
- (NSRegularExpression *)_regexForFindingFrameworkNameInHeaderPath
{
	// Look for a match with .../SomeFrameworkName.framework/...
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

	NSDictionary *captureGroups = [AKRegexUtils matchRegex:[self _regexForFindingFrameworkNameInHeaderPath] toEntireString:headerPath].object;
	NSString *inferredFrameworkName = captureGroups[@1];
	if (inferredFrameworkName) {
		QLog(@"+++ Framework %@ for %@ was inferred from header path", inferredFrameworkName, self);
	}
	return inferredFrameworkName;
}

- (NSString *)_tryToInferFrameworkNameFromDocPath:(NSString *)docPath
{
	if (docPath == nil) {
		return nil;
	}

	NSString *inferredFrameworkName;  //TODO: Fill this in.
	if (inferredFrameworkName) {
		QLog(@"+++ Framework %@ for %@ was inferred from doc path", inferredFrameworkName, self);
	}
	return inferredFrameworkName;
}

@end
