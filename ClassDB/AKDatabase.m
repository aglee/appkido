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
		_classItemsByName = [[NSMutableDictionary alloc] init];
		_protocolItemsByName = [[NSMutableDictionary alloc] init];
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
	[self _pruneClassItemsWithoutTokens];  //TODO: Does this work?
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

- (NSArray *)classesForFrameworkNamed:(NSString *)frameworkName
{
	NSMutableArray *classItems = [NSMutableArray array];
	for (AKClassItem *classItem in [self allClasses]) {
		if ([classItem.frameworkName isEqualToString:frameworkName]) 	{
			[classItems addObject:classItem];
		}
	}
	return classItems;
}

- (NSArray *)rootClasses
{
	NSMutableArray *result = [NSMutableArray array];
	for (AKClassItem *classItem in [self allClasses]) {
		if (classItem.parentClass == nil) {
			[result addObject:classItem];
		}
	}
	return result;
}

- (NSArray *)allClasses
{
	return self.classItemsByName.allValues;
}

- (AKClassItem *)classWithName:(NSString *)className
{
	return self.classItemsByName[className];
}

#pragma mark - Getters and setters -- protocols

- (NSArray *)formalProtocolsForFrameworkNamed:(NSString *)frameworkName
{
	return [self _allProtocolsForFrameworkNamed:frameworkName withInformalFlag:NO];
}

- (NSArray *)informalProtocolsForFrameworkNamed:(NSString *)frameworkName
{
	return [self _allProtocolsForFrameworkNamed:frameworkName withInformalFlag:YES];
}

- (NSArray *)allProtocols
{
	return _protocolItemsByName.allValues;
}

- (AKProtocolItem *)protocolWithName:(NSString *)name
{
	return _protocolItemsByName[name];
}

- (void)addProtocolItem:(AKProtocolItem *)protocolItem
{
	// Do nothing if we already have a protocol with the same name.
	NSString *protocolName = protocolItem.tokenName;
	if (_protocolItemsByName[protocolName]) {
		DIGSLogDebug(@"Trying to add protocol [%@] again", protocolName);
		return;
	}

	// Add the protocol to our lookup by protocol name.
	_protocolItemsByName[protocolName] = protocolItem;
}

#pragma mark - Getters and setters -- functions

- (NSArray *)functionsGroupsForFrameworkNamed:(NSString *)frameworkName
{
	return _functionsGroupListsByFramework[frameworkName];
}

- (AKGroupItem *)functionsGroupNamed:(NSString *)groupName inFrameworkNamed:(NSString *)frameworkName
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
	NSString *groupName = groupItem.tokenName;

	if (groupsByName[groupName]) {
		DIGSLogWarning(@"Trying to add functions group [%@] again", groupName);
	} else {
		[groupList addObject:groupItem];
		groupsByName[groupItem.tokenName] = groupItem;
	}
}

#pragma mark - Getters and setters -- globals

- (NSArray *)globalsGroupsForFrameworkNamed:(NSString *)frameworkName
{
	return _globalsGroupListsByFramework[frameworkName];
}

- (AKGroupItem *)globalsGroupNamed:(NSString *)groupName
				  inFrameworkNamed:(NSString *)frameworkName
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
	NSString *groupName = groupItem.tokenName;

	if (groupsByName[groupName]) {
		DIGSLogWarning(@"Trying to add globals group [%@] again", groupName);
	} else {
		[groupList addObject:groupItem];
		groupsByName[groupItem.tokenName] = groupItem;
	}
}

#pragma mark - Private methods - misc

- (NSArray *)_allProtocolsForFrameworkNamed:(NSString *)fwName
						   withInformalFlag:(BOOL)informalFlag
{
	NSMutableArray *result = [NSMutableArray array];
	for (AKProtocolItem *protocolItem in [self allProtocols]) {
		if ((protocolItem.isInformal == informalFlag)
			&& [protocolItem.frameworkName isEqualToString:fwName]) {

			[result addObject:protocolItem];
		}
	}
	return result;
}

#pragma mark - Private methods - populating the database - misc

- (AKDocSetQuery *)_queryWithEntityName:(NSString *)entityName
{
	return [[AKDocSetQuery alloc] initWithDocSetIndex:self.docSetIndex entityName:entityName];
}

- (NSArray *)_arrayWithTokensForLanguage:(NSString *)languageName
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

- (void)_pruneClassItemsWithoutTokens  //TODO: See if there is a better way.
{
	for (NSString *className in self.classItemsByName.allKeys) {
		AKClassItem *classItem = self.classItemsByName[className];
		if (classItem.token == nil) {
			QLog(@"+++ class '%@' has no token; removing it", className);
			self.classItemsByName[className] = nil;
		}
	}
}

@end
