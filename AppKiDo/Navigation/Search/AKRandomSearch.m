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

- (NSString *)selectRandomTokenName
{
	// Collect all the token names in the database.  If multiple tokens have the
	// same name, that name will appear in the array multiple times.  I *think*
	// that's what we want.
	//TODO: How about AKDatabase having an allTokens method?
	NSMutableArray *allTokens = [NSMutableArray array];

	[self _addClassTokensToArray:allTokens];
	[self _addClassMemberTokensToArray:allTokens];
	[self _addProtocolTokensToArray:allTokens];
	[self _addProtocolMemberTokensToArray:allTokens];
	[self _addTokensFromFrameworkTokenClustersToArray:allTokens];

	// Make a random selection.
	NSUInteger randomArrayIndex = (arc4random() % allTokens.count);
	AKToken *randomToken = allTokens[randomArrayIndex];
	return randomToken.name;
}

#pragma mark - Private methods

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
