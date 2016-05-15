/*
 * AKDatabase.m
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDatabase+Private.h"

@implementation AKDatabase

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDocSetIndex:(DocSetIndex *)docSetIndex
{
	self = [super init];
	if (self) {
		_docSetIndex = docSetIndex;
		_frameworkNames = @[];
		_classTokensByName = [[NSMutableDictionary alloc] init];
		_protocolTokensByName = [[NSMutableDictionary alloc] init];
		_functionsGroupListsByFramework = [[NSMutableDictionary alloc] init];
		_functionsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

		_globalsGroupListsByFramework = [[NSMutableDictionary alloc] init];
		_globalsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithDocSetIndex:nil];
}

#pragma mark - Populating the database

- (void)populate
{
	[self _importFrameworkNames];
	[self _importObjectiveCTokens];
	[self _importCTokens];

	// Post-processing.
	[self _pruneClassTokensWithoutTokens];  //TODO: Does this work?
}

#pragma mark - Getters and setters -- frameworks

- (NSArray *)sortedFrameworkNames
{
	return self.frameworkNames;
}

- (BOOL)hasFrameworkWithName:(NSString *)frameworkName
{
	return [self.frameworkNames containsObject:frameworkName];
}

#pragma mark - Getters and setters -- classes

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

#pragma mark - Getters and setters -- protocols

- (NSArray *)formalProtocolsForFramework:(NSString *)frameworkName
{
	return [self _allProtocolsForFramework:frameworkName withInformalFlag:NO];
}

- (NSArray *)informalProtocolsForFramework:(NSString *)frameworkName
{
	return [self _allProtocolsForFramework:frameworkName withInformalFlag:YES];
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

#pragma mark - Getters and setters -- functions

- (NSArray *)functionsGroupsForFramework:(NSString *)frameworkName
{
	return _functionsGroupListsByFramework[frameworkName];
}

- (AKGroupItem *)functionsGroupNamed:(NSString *)groupName inFramework:(NSString *)frameworkName
{
	return _functionsGroupsByFrameworkAndGroup[frameworkName][groupName];
}

- (void)addFunctionsGroup:(AKGroupItem *)groupItem
{
	NSString *frameworkName = groupItem.frameworkName;

	// See if we have any functions groups in the framework yet.
	NSMutableArray *groupList = nil;
	NSMutableDictionary *groupsByName = _functionsGroupsByFrameworkAndGroup[frameworkName];

	if (groupsByName) {
		groupList = _functionsGroupListsByFramework[frameworkName];
	} else {
		groupsByName = [NSMutableDictionary dictionary];
		_functionsGroupsByFrameworkAndGroup[frameworkName] = groupsByName;

		groupList = [NSMutableArray array];
		_functionsGroupListsByFramework[frameworkName] = groupList;
	}

	// Add the functions group if it isn't already in the framework.
	NSString *groupName = groupItem.name;

	if (groupsByName[groupName]) {
		DIGSLogWarning(@"Trying to add functions group [%@] again", groupName);
	} else {
		[groupList addObject:groupItem];
		groupsByName[groupItem.name] = groupItem;
	}
}

#pragma mark - Getters and setters -- globals

- (NSArray *)globalsGroupsForFramework:(NSString *)frameworkName
{
	return _globalsGroupListsByFramework[frameworkName];
}

- (AKGroupItem *)globalsGroupNamed:(NSString *)groupName
				  inFramework:(NSString *)frameworkName
{
	return _globalsGroupsByFrameworkAndGroup[frameworkName][groupName];
}

- (void)addGlobalsGroup:(AKGroupItem *)groupItem
{
	NSString *frameworkName = groupItem.frameworkName;

	// See if we have any globals groups in the framework yet.
	NSMutableArray *groupList = nil;
	NSMutableDictionary *groupsByName = _globalsGroupsByFrameworkAndGroup[frameworkName];

	if (groupsByName) {
		groupList = _globalsGroupListsByFramework[frameworkName];
	} else {
		groupsByName = [NSMutableDictionary dictionary];
		_globalsGroupsByFrameworkAndGroup[frameworkName] = groupsByName;

		groupList = [NSMutableArray array];
		_globalsGroupListsByFramework[frameworkName] = groupList;
	}

	// Add the globals group if it isn't already in the framework.
	NSString *groupName = groupItem.name;

	if (groupsByName[groupName]) {
		DIGSLogWarning(@"Trying to add globals group [%@] again", groupName);
	} else {
		[groupList addObject:groupItem];
		groupsByName[groupItem.name] = groupItem;
	}
}

#pragma mark - Private methods - misc

- (NSArray *)_allProtocolsForFramework:(NSString *)fwName
						   withInformalFlag:(BOOL)informalFlag
{
	NSMutableArray *result = [NSMutableArray array];
	for (AKProtocolToken *protocolToken in [self allProtocols]) {
		if ((protocolToken.isInformal == informalFlag)
			&& [protocolToken.frameworkName isEqualToString:fwName]) {

			[result addObject:protocolToken];
		}
	}
	return result;
}

#pragma mark - Private methods - populating the database - misc

- (AKDocSetQuery *)_queryWithEntityName:(NSString *)entityName
{
	return [[AKDocSetQuery alloc] initWithDocSetIndex:self.docSetIndex entityName:entityName];
}

- (NSArray *)_arrayWithTokenMOsForLanguage:(NSString *)languageName
{
	NSError *error;
	AKDocSetQuery *query = [self _queryWithEntityName:@"Token"];
	query.predicateString = [NSString stringWithFormat:@"language.fullName = '%@'", languageName];
	return [query fetchObjectsWithError:&error];  //TODO: Handle error.
}

- (void)_importFrameworkNames
{
	AKDocSetQuery *query = [self _queryWithEntityName:@"Header"];
	query.distinctKeyPathsString = @"frameworkName";
	query.predicateString = @"frameworkName != NULL";

	NSError *error;
	NSArray *fetchedObjects = [query fetchObjectsWithError:&error];  //TODO: Handle error.
	NSArray *frameworkNames = [fetchedObjects valueForKey:@"frameworkName"];
	frameworkNames = [frameworkNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

	self.frameworkNames = frameworkNames;
}

- (void)_pruneClassTokensWithoutTokens  //TODO: See if there is a better way.
{
	for (NSString *className in self.classTokensByName.allKeys) {
		AKClassToken *classToken = self.classTokensByName[className];
		if (classToken.tokenMO == nil) {
			QLog(@"+++ class '%@' has no token; removing it", className);
			self.classTokensByName[className] = nil;
		}
	}
}

@end
