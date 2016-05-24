//
//  AKRandomSearch.m
//  AppKiDo
//
//  Created by Andy Lee on 3/14/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKRandomSearch.h"
#import "AKClassToken.h"
#import "AKDatabase.h"
#import "AKProtocolToken.h"
#import "DIGSLog.h"

@interface AKRandomSearch ()
@property (readonly) AKDatabase *database;
@end

@implementation AKRandomSearch

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDatabase:(AKDatabase *)database
{
	NSParameterAssert(database != nil);
	self = [super init];
	if (self) {
		_database = database;
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithDatabase:nil];
}


#pragma mark - Random selection

- (NSString *)selectRandomName
{
	// Collect all the token names in the database.  If multiple tokens have the
	// same name, that name will appear in the array multiple times.  I *think*
	// that's what we want.
	NSMutableArray<id<AKNamed>> *allNamedObjects = [NSMutableArray array];

	[self _addFrameworksToArray:allNamedObjects];
	[self _addClassTokensToArray:allNamedObjects];
	[self _addClassMemberTokensToArray:allNamedObjects];
	[self _addProtocolTokensToArray:allNamedObjects];
	[self _addProtocolMemberTokensToArray:allNamedObjects];
	[self _addTokensFromFrameworkTokenClustersToArray:allNamedObjects];

	// Make a random selection.
	NSUInteger randomArrayIndex = (arc4random() % allNamedObjects.count);
	AKToken *randomToken = allNamedObjects[randomArrayIndex];
	return randomToken.name;
}

#pragma mark - Private methods

- (void)_addFrameworksToArray:(NSMutableArray *)tokenArray
{
	[tokenArray addObjectsFromArray:self.database.sortedFrameworks];
}

- (void)_addClassTokensToArray:(NSMutableArray *)tokenArray
{
	[tokenArray addObjectsFromArray:self.database.allClasses];
}

- (void)_addClassMemberTokensToArray:(NSMutableArray *)tokenArray
{
	for (AKClassToken *classToken in self.database.allClasses) {
		[tokenArray addObjectsFromArray:classToken.propertyTokens];
		[tokenArray addObjectsFromArray:classToken.classMethodTokens];
		[tokenArray addObjectsFromArray:classToken.instanceMethodTokens];
		[tokenArray addObjectsFromArray:classToken.delegateMethodTokens];
		[tokenArray addObjectsFromArray:classToken.dataTypeTokens];
		[tokenArray addObjectsFromArray:classToken.constantTokens];
		[tokenArray addObjectsFromArray:classToken.notificationTokens];
	}
}

- (void)_addProtocolTokensToArray:(NSMutableArray *)tokenArray
{
	[tokenArray addObjectsFromArray:self.database.allProtocols];
}

- (void)_addProtocolMemberTokensToArray:(NSMutableArray *)tokenArray
{
	for (AKProtocolToken *protocolToken in self.database.allProtocols) {
		[tokenArray addObjectsFromArray:protocolToken.propertyTokens];
		[tokenArray addObjectsFromArray:protocolToken.classMethodTokens];
		[tokenArray addObjectsFromArray:protocolToken.instanceMethodTokens];
		[tokenArray addObjectsFromArray:protocolToken.notificationTokens];
	}
}

- (void)_addTokensFromFrameworkTokenClustersToArray:(NSMutableArray *)tokenArray  //TODO: Clean this up.
{
//	for (NSString *fwName in self.database.frameworkNames) {
//		for (AKGroupItem *groupItem in [self.database functionsGroupsForFramework:fwName]) {
//			[self _addTokens:groupItem.subitems toArray:tokenArray];
//		}
//	}
}

@end
