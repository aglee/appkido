/*
 * AKDatabase.m
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDatabase.h"
#import "AKClassToken.h"
#import "AKManagedObjectQuery.h"
#import "AKFramework.h"
#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"
#import "AKProtocolToken.h"
#import "AKRegexUtils.h"
#import "AKResult.h"

@implementation AKDatabase

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDocSetIndex:(DocSetIndex *)docSetIndex
{
	self = [super init];
	if (self) {
		_docSetIndex = docSetIndex;
		_frameworksGroup = [[AKNamedObjectGroup alloc] initWithName:@"Frameworks"];
		_classTokensByName = [[NSMutableDictionary alloc] init];
		_protocolTokensByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithDocSetIndex:nil];
}

#pragma mark - Getters and setters

- (NSArray *)sortedFrameworkNames
{
	return self.frameworksGroup.sortedObjectNames;
}

- (NSArray *)sortedFrameworks
{
	return self.frameworksGroup.sortedObjects;
}

#pragma mark - Populating the database

- (void)populate
{
	// Prefetch all these objects so they don't have to be individually fetched
	// later when we iterate through various objects.  Saves a few seconds.
	NSArray *keepAround = @[
							[[self _queryWithEntityName:@"Token"] fetchObjects].object,
							[[self _queryWithEntityName:@"TokenMetainformation"] fetchObjects].object,
							[[self _queryWithEntityName:@"Header"] fetchObjects].object,
							[[self _queryWithEntityName:@"FilePath"] fetchObjects].object,
							];

	// Load up our internal data structures with stuff from the docset index.
	[self _importFrameworks];
	[self _importObjectiveCTokens];
	[self _importCTokens];

	// Don't let ARC get rid of keepAround until we get here.
	[keepAround self];
}

#pragma mark - Frameworks

- (AKFramework *)frameworkWithName:(NSString *)frameworkName
{
	return (AKFramework *)[self.frameworksGroup objectWithName:frameworkName];
}

#pragma mark - Class tokens

- (NSArray *)classesForFramework:(NSString *)frameworkName
{
	NSMutableArray *classTokens = [NSMutableArray array];
	for (AKClassToken *classToken in [self allClasses]) {
		if ([classToken.frameworkName isEqualToString:frameworkName]) 	{
			[classTokens addObject:classToken];
		}
	}
	return classTokens;
}

- (NSArray *)rootClasses
{
	NSMutableArray *result = [NSMutableArray array];
	for (AKClassToken *classToken in [self allClasses]) {
		if (classToken.parentClass == nil) {
			[result addObject:classToken];
		}
	}
	return result;
}

- (NSArray *)allClasses
{
	return self.classTokensByName.allValues;
}

- (AKClassToken *)classWithName:(NSString *)className
{
	return self.classTokensByName[className];
}

#pragma mark - Protocol tokens

- (NSArray *)protocolsForFramework:(NSString *)frameworkName
{
	AKFramework *framework = (AKFramework *)[self.frameworksGroup objectWithName:frameworkName];
	return framework.protocolsGroup.sortedObjects;
}

- (NSArray *)allProtocols
{
	return _protocolTokensByName.allValues;
}

- (AKProtocolToken *)protocolWithName:(NSString *)name
{
	return _protocolTokensByName[name];
}

#pragma mark - Private methods - populating the database - misc

- (AKManagedObjectQuery *)_queryWithEntityName:(NSString *)entityName
{
	return [[AKManagedObjectQuery alloc] initWithMOC:self.docSetIndex.managedObjectContext entityName:entityName];
}

- (NSArray *)_arrayWithTokenMOsForLanguage:(NSString *)languageName
{
	AKManagedObjectQuery *query = [self _queryWithEntityName:@"Token"];
	query.predicateString = [NSString stringWithFormat:@"language.fullName = '%@'", languageName];
	AKResult *result = [query fetchObjects];
	return result.object;  //TODO: Handle error.
}

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
		frameworkName = @"<UNKNOWN FRAMEWORK>";
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

	NSString *inferredFrameworkName;
	if (inferredFrameworkName) {
		QLog(@"+++ Framework %@ for %@ was inferred from doc path", inferredFrameworkName, self);
	}
	return inferredFrameworkName;
}

@end
