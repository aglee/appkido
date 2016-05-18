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
		_constantsCluster = [[AKNamedObjectCluster alloc] initWithName:@"Constants"];
		_enumsCluster = [[AKNamedObjectCluster alloc] initWithName:@"Enums"];
		_functionsCluster = [[AKNamedObjectCluster alloc] initWithName:@"Functions"];
		_macrosCluster = [[AKNamedObjectCluster alloc] initWithName:@"Macros"];
		_typedefsCluster = [[AKNamedObjectCluster alloc] initWithName:@"Typedef"];
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

#pragma mark - Populating the database

- (void)populate
{
	[self _importFrameworks];
	[self _importObjectiveCTokens];
	[self _importCTokens];
}

#pragma mark - Frameworks

- (BOOL)hasFrameworkWithName:(NSString *)frameworkName
{
	return ([self.frameworksGroup objectWithName:frameworkName] != nil);
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
	return [self _allProtocolsForFramework:frameworkName];
}

- (NSArray *)allProtocols
{
	return _protocolTokensByName.allValues;
}

- (AKProtocolToken *)protocolWithName:(NSString *)name
{
	return _protocolTokensByName[name];
}

- (void)addProtocolToken:(AKProtocolToken *)protocolToken
{
	// Do nothing if we already have a protocol with the same name.
	NSString *protocolName = protocolToken.name;
	if (_protocolTokensByName[protocolName]) {
		DIGSLogDebug(@"Trying to add protocol [%@] again", protocolName);
		return;
	}

	// Add the protocol to our lookup by protocol name.
	_protocolTokensByName[protocolName] = protocolToken;
}

#pragma mark - Function tokens


#pragma mark - Private methods - misc

- (NSArray *)_allProtocolsForFramework:(NSString *)fwName
{
	NSMutableArray *result = [NSMutableArray array];
	for (AKProtocolToken *protocolToken in [self allProtocols]) {
		if ([protocolToken.frameworkName isEqualToString:fwName]) {
			[result addObject:protocolToken];
		}
	}
	return result;
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

@end
