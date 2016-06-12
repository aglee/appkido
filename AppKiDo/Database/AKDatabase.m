/*
 * AKDatabase.m
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDatabase+Private.h"
#import "AKClassToken.h"
#import "DocSetIndex.h"
#import "AKFramework.h"
#import "AKInstalledSDK.h"
#import "AKManagedObjectQuery.h"
#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"
#import "AKProtocolToken.h"
#import "AKRegexUtils.h"
#import "AKResult.h"
#import "DIGSLog.h"

@implementation AKDatabase

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDocSetIndex:(DocSetIndex *)docSetIndex
								SDK:(AKInstalledSDK *)installedSDK
{
	NSParameterAssert(docSetIndex != nil);
	NSParameterAssert(installedSDK != nil);
	self = [super init];
	if (self) {
		_docSetIndex = docSetIndex;
		_referenceSDK = installedSDK;
		_frameworksGroup = [[AKNamedObjectGroup alloc] initWithName:@"Frameworks"];
		_classTokensByName = [[NSMutableDictionary alloc] init];
		_protocolTokensByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithDocSetIndex:nil SDK:nil];
}

#pragma mark - Getters and setters

- (NSArray *)sortedFrameworkNames
{
	return self.frameworksGroup.sortedObjectNames;
}

- (NSArray *)frameworks
{
	return self.frameworksGroup.objects;
}

#pragma mark - Populating the database

- (void)populate
{
	// Prefetch all these objects so they don't have to be individually fetched
	// later when we iterate through various objects.  Saves a few seconds.
	NSArray *entitiesToPrefetch = @[ @"Token", @"TokenMetainformation", @"Header", @"FilePath", @"Node" ];
	NSMutableArray *keepAround = [NSMutableArray array];
	for (NSString *entityName in entitiesToPrefetch) {
		AKManagedObjectQuery *query = [self _queryWithEntityName:entityName];
		query.returnsObjectsAsFaults = NO;
		NSArray *fetchedObjects = [query fetchObjects].object;
		QLog(@"+++ Pre-fetched %zd instances of %@", fetchedObjects.count, entityName);
		[keepAround addObject:fetchedObjects];
	}

	// Load up our internal data structures with stuff from the docset index.
	[self _importFrameworks];
	[self _importObjectiveCTokens];
	[self _importCTokens];

	// This will keep ARC from freeing keepAround until we've finished importing.
	[keepAround self];
}

#pragma mark - Frameworks

- (AKFramework *)frameworkWithName:(NSString *)frameworkName
{
	return (AKFramework *)[self.frameworksGroup objectWithName:frameworkName];
}

#pragma mark - Class tokens

- (NSArray *)classTokensInFramework:(NSString *)frameworkName
{
	NSMutableArray *classTokens = [NSMutableArray array];
	for (AKClassToken *classToken in [self allClassTokens]) {
		if ([classToken.frameworkName isEqualToString:frameworkName]) 	{
			[classTokens addObject:classToken];
		}
	}
	return classTokens;
}

- (NSArray *)rootClassTokens
{
	NSMutableArray *result = [NSMutableArray array];
	for (AKClassToken *classToken in [self allClassTokens]) {
		if (classToken.superclassToken == nil) {
			[result addObject:classToken];
		}
	}
	return result;
}

- (NSArray *)allClassTokens
{
	return self.classTokensByName.allValues;
}

- (AKClassToken *)classTokenWithName:(NSString *)className
{
	return self.classTokensByName[className];
}

#pragma mark - Protocol tokens

- (NSArray *)protocolTokensInFramework:(NSString *)frameworkName
{
	AKFramework *framework = (AKFramework *)[self.frameworksGroup objectWithName:frameworkName];
	return framework.protocolsGroup.objects;
}

- (NSArray *)allProtocolTokens
{
	return _protocolTokensByName.allValues;
}

- (AKProtocolToken *)protocolTokenWithName:(NSString *)name
{
	return _protocolTokensByName[name];
}

@end
