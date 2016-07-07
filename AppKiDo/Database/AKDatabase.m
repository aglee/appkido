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
	// Prefetch all instances of these entities from the docset index.  Saves a
	// few seconds because they don't have to be individually fetched later.
	NSArray *entityNames = @[ @"Token", @"TokenMetainformation", @"Header", @"FilePath", @"Node" ];
	NSArray *keepAround = [self _fetchAllInstancesOfEntitiesWithNames:entityNames];

	// Load up our internal data structures with stuff from the docset index.
	[self _importFrameworks];
	[self _importObjectiveCTokens];
	[self _importCTokens];

	// Post-processing: remove classes, protocols, and frameworks with no content.
	[self _pruneTokensAndFrameworks];

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

#pragma mark - Private methods

- (NSArray *)_fetchAllInstancesOfEntitiesWithNames:(NSArray *)entityNames
{
	NSMutableArray *arrayOfFetchedObjectArrays = [NSMutableArray array];

	for (NSString *entityName in entityNames) {
		AKManagedObjectQuery *query = [self _queryWithEntityName:entityName];
		query.returnsObjectsAsFaults = NO;
		NSArray *fetchedObjects = [query fetchObjects].object;
		QLog(@"+++ Pre-fetched %zd instances of %@", fetchedObjects.count, entityName);
		[arrayOfFetchedObjectArrays addObject:fetchedObjects];
	}

	return arrayOfFetchedObjectArrays;
}

// One way we might have content-free class tokens is from parsing .h files in
// sample code.  Another way is from parsing header files that contain
// declarations of obsolete classes.
- (void)_pruneTokensAndFrameworks
{
	// Remove class and protocol tokens that have no content.
	[self _removeEmptyClassTokens];
	[self _removeEmptyProtocolTokens];

	// Remove frameworks that have no content.  Do so *after* the above, since
	// the above pruning may cause frameworks to become empty.
	for (AKFramework *framework in [self.frameworks copy]) {
		if (!framework.hasContent) {
			//QLog(@"+++ Removing content-free framework %@.", framework.name);
			[self _removeFramework:framework];
		}
	}
}

- (void)_removeEmptyClassTokens
{
	while (YES) {
		NSUInteger numRemoved = 0;

		for (AKClassToken *classToken in self.allClassTokens) {
			if (!classToken.hasContent) {
				//QLog(@"+++ Removing content-free class %@.", classToken.name);

				[classToken tearDown];
				AKFramework *framework = [self frameworkWithName:classToken.frameworkName];
				[framework.classesGroup removeNamedObject:classToken];
				self.classTokensByName[classToken.name] = nil;

				numRemoved++;
			}
		}

		if (numRemoved == 0) {
			break;
		}
	}
}

- (void)_removeEmptyProtocolTokens
{
	while (YES) {
		NSUInteger numRemoved = 0;

		for (AKProtocolToken *protocolToken in self.allProtocolTokens) {
			if (!protocolToken.hasContent) {
				//QLog(@"+++ Removing content-free protocol %@.", protocolToken.name);

				[protocolToken tearDown];
				AKFramework *framework = [self frameworkWithName:protocolToken.frameworkName];
				[framework.protocolsGroup removeNamedObject:protocolToken];
				self.protocolTokensByName[protocolToken.name] = nil;

				numRemoved++;
			}
		}

		if (numRemoved == 0) {
			break;
		}
	}
}

- (void)_removeFramework:(AKFramework *)framework
{
	[self.frameworksGroup removeNamedObject:framework];
}

@end
