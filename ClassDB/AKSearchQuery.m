/*
 * AKSearchQuery.m
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSearchQuery.h"
#import "DIGSLog.h"
#import "AKClassToken.h"
#import "AKClassTopic.h"
#import "AKDatabase.h"
#import "AKDocLocator.h"
#import "AKFramework.h"
#import "AKFrameworkTopic.h"
#import "AKMethodToken.h"
#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"
#import "AKProtocolToken.h"
#import "AKProtocolTopic.h"
#import "AKSortUtils.h"
#import "AKSubtopic.h"
#import "AKToken.h"
#import "NSString+AppKiDo.h"

@interface AKSearchQuery ()
@property (nonatomic, strong) AKDatabase *database;
// Caches search results.  Made this strong rather than copy because for our
// internal purposes (modifiying the array in place), we want the self-same
// NSMutableArray, and a copy won't do.  Copy wouldn't work anyway, because
// it causes the getter to return an immutable NSArray; the resulting
// exception on my attempt to modify the array was how I realized I needed
// to change this from copy to strong.
@property (nonatomic, strong) NSMutableArray *searchResults;
@end

@implementation AKSearchQuery

@synthesize searchString = _searchString;
@synthesize includesClassesAndProtocols = _includesClassesAndProtocols;
@synthesize includesMembers = _includesMembers;
@synthesize includesFunctions = _includesFunctions;
@synthesize includesGlobals = _includesGlobals;
@synthesize ignoresCase = _ignoresCase;
@synthesize searchComparison = _searchComparison;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDatabase:(AKDatabase *)db
{
	NSParameterAssert(db != nil);
	self = [super init];
	if (self) {
		_database = db;
		_searchString = nil;
		_includesClassesAndProtocols = YES;
		_includesMembers = YES;
		_includesFunctions = YES;
		_includesGlobals = YES;
		_ignoresCase = YES;
		_searchComparison = AKSearchForSubstring;
		_searchResults = [[NSMutableArray alloc] init];
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithDatabase:nil];
}

#pragma mark - Getters and setters

- (NSString *)searchString
{
	return _searchString;
}

- (void)setSearchString:(NSString *)searchString
{
	if (_searchString == searchString || [_searchString isEqualToString:searchString]) {
		return;
	}

	// Set the ivar.
	_searchString = [searchString copy];

	// Update other ivars.
	self.searchResults = nil;
}

- (BOOL)includesClassesAndProtocols
{
	return _includesClassesAndProtocols;
}

- (void)setIncludesClassesAndProtocols:(BOOL)flag
{
	if (_includesClassesAndProtocols != flag) {
		_includesClassesAndProtocols = flag;
		self.searchResults = nil;
	}
}

- (BOOL)includesMembers
{
	return _includesMembers;
}

- (void)setIncludesMembers:(BOOL)flag
{
	if (_includesMembers != flag) {
		_includesMembers = flag;
		self.searchResults = nil;
	}
}

- (BOOL)includesFunctions
{
	return _includesFunctions;
}

- (void)setIncludesFunctions:(BOOL)flag
{
	if (_includesFunctions != flag) {
		_includesFunctions = flag;
		self.searchResults = nil;
	}
}

- (BOOL)includesGlobals
{
	return _includesGlobals;
}

- (void)setIncludesGlobals:(BOOL)flag
{
	if (_includesGlobals != flag) {
		_includesGlobals = flag;
		self.searchResults = nil;
	}
}

- (BOOL)ignoresCase
{
	return _ignoresCase;
}

- (void)setIgnoresCase:(BOOL)flag
{
	if (_ignoresCase != flag) {
		_ignoresCase = flag;
		self.searchResults = nil;
	}
}

- (AKSearchComparison)searchComparison
{
	return _searchComparison;
}

- (void)setSearchComparison:(AKSearchComparison)searchComparison
{
	if (_searchComparison != searchComparison) {
		_searchComparison = searchComparison;
		self.searchResults = nil;
	}
}

#pragma mark - Searching

- (void)includeEverythingInSearch
{
	[self setIncludesClassesAndProtocols:YES];
	[self setIncludesMembers:YES];
	[self setIncludesFunctions:YES];
	[self setIncludesGlobals:YES];
}

- (NSArray *)performSearch
{
	if (self.searchResults == nil) {
		[self _refreshCachedSearchedResults];
	}
	return self.searchResults;
}

#pragma mark - Private methods - general

- (void)_refreshCachedSearchedResults
{
	self.searchResults = [NSMutableArray array];

	if (self.searchString.length == 0) {
		return;
	}

	// Each of the following calls appends its results to searchResults.
	if (self.includesClassesAndProtocols) {
		[self _searchClasses];
		[self _searchProtocols];
	}
	if (self.includesMembers) {
		[self _searchClassMembers];
		[self _searchProtocolMembers];
	}
	if (self.includesFunctions) {
		[self _searchFunctions];
	}
	if (self.includesGlobals) {
		[self _searchGlobals];
	}

	// Sort the results.
	[AKDocLocator sortArrayOfDocLocators:self.searchResults];
}

- (BOOL)_matchesString:(NSString *)string
{
	NSString *haystack = (self.ignoresCase ? string.uppercaseString : string);
	NSString *needle = (self.ignoresCase ? self.searchString.uppercaseString : self.searchString);
	switch (self.searchComparison) {
		case AKSearchForSubstring: {
			return [haystack ak_contains:needle];
		}

		case AKSearchForExactMatch: {
			return [haystack isEqualToString:needle];
		}

		case AKSearchForPrefix: {
			return [haystack hasPrefix:needle];
		}

		default: {
			DIGSLogDebug(@"Unexpected search comparison mode %d", self.searchComparison);
			return NO;
		}
	}
}

- (BOOL)_matchesToken:(AKToken *)token
{
	return [self _matchesString:token.name];
}

#pragma mark - Private methods - searching behaviors and their members

- (void)_searchClasses
{
	for (AKClassToken *classToken in self.database.allClasses) {
		if ([self _matchesToken:classToken]) 	{
			AKClassTopic *topic = [[AKClassTopic alloc] initWithClassToken:classToken];
			[self.searchResults addObject:[AKDocLocator withTopic:topic subtopicName:nil docName:nil]];
		}
	}
}

- (void)_searchProtocols
{
	for (AKProtocolToken *protocolToken in self.database.allProtocols) {
		if ([self _matchesToken:protocolToken]) {
			AKProtocolTopic *topic = [[AKProtocolTopic alloc] initWithProtocolToken:protocolToken];
			[self.searchResults addObject:[AKDocLocator withTopic:topic subtopicName:nil docName:nil]];
		}
	}
}

- (void)_searchClassMembers
{
	for (AKClassToken *classToken in self.database.allClasses) {
		AKClassTopic *topic = [[AKClassTopic alloc] initWithClassToken:classToken];

		// Search members common to all behaviors.
		[self _searchMembersUnderBehaviorTopic:topic];

		// Search members specific to classes.
		[self _searchTokens:[classToken documentedDelegateMethods]
			  underSubtopic:AKDelegateMethodsSubtopicName
			ofBehaviorTopic:topic];
		[self _searchTokens:[classToken documentedNotifications]
			  underSubtopic:AKNotificationsSubtopicName
			ofBehaviorTopic:topic];
	}
}

- (void)_searchProtocolMembers
{
	for (AKProtocolToken *protocolToken in self.database.allProtocols) {
		AKProtocolTopic *topic = [[AKProtocolTopic alloc] initWithProtocolToken:protocolToken];
		[self _searchMembersUnderBehaviorTopic:topic];
	}
}

- (void)_searchMembersUnderBehaviorTopic:(AKBehaviorTopic *)behaviorTopic
{
	AKBehaviorToken *behaviorToken = (AKBehaviorToken *)[behaviorTopic topicToken];

	// Search the behavior's properties.
	[self _searchTokens:[behaviorToken propertyTokens]
		  underSubtopic:AKPropertiesSubtopicName
		ofBehaviorTopic:behaviorTopic];

	// If the search string has the form "setXYZ", search the class's
	// properties for "XYZ".
	if (self.searchString.length > 3 && [self.searchString hasPrefix:@"set"]) {
		// Kludge to temporarily set _searchString to "XYZ".  Don't use the setter method, because that will clear self.searchResults.
		//TODO: But this only works if case-insensitive.  Need to tweak the first N characters in that case.
		NSString *savedSearchString = _searchString;
		_searchString = [_searchString substringFromIndex:3];
		{{
			[self _searchTokens:[behaviorToken propertyTokens]
				  underSubtopic:AKPropertiesSubtopicName
				ofBehaviorTopic:behaviorTopic];
		}}
		_searchString = savedSearchString;
	}

	// Search the behavior's class methods.
	[self _searchTokens:[behaviorToken classMethodTokens]
		  underSubtopic:AKClassMethodsSubtopicName
		ofBehaviorTopic:behaviorTopic];

	// Search the behavior's instance methods.
	[self _searchTokens:[behaviorToken instanceMethodTokens]
		  underSubtopic:AKInstanceMethodsSubtopicName
		ofBehaviorTopic:behaviorTopic];
}

- (void)_searchTokens:(NSArray *)tokenArray
		underSubtopic:(NSString *)subtopicName
	  ofBehaviorTopic:(AKBehaviorTopic *)topic
{
	for (AKToken *token in tokenArray) {
		if ([self _matchesToken:token]) {
			[self.searchResults addObject:[AKDocLocator withTopic:topic
													 subtopicName:subtopicName
														  docName:token.name]];
		}
	}
}

#pragma mark - Private methods - searching token clusters with AKFramework

- (void)_searchFunctions
{
	for (AKFramework *framework in self.database.sortedFrameworks) {
		[self _searchFunctionsInFramework:framework];
	}
}

- (void)_searchFunctionsInFramework:(AKFramework *)framework
{
	NSArray *tokenClusters = @[ framework.functionsCluster ];
	AKFrameworkTopic *frameworkTopic = [[AKFrameworkTopic alloc] initWithFramework:framework];
	[self _searchTokenClusters:tokenClusters inFrameworkTopic:frameworkTopic];
}

- (void)_searchGlobals
{
	for (AKFramework *framework in self.database.sortedFrameworks) {
		[self _searchGlobalsInFramework:framework];
	}
}

- (void)_searchGlobalsInFramework:(AKFramework *)framework
{
	NSArray *tokenClusters = @[ framework.enumsCluster,
								framework.macrosCluster,
								framework.typedefsCluster,
								framework.constantsCluster ];
	AKFrameworkTopic *frameworkTopic = [[AKFrameworkTopic alloc] initWithFramework:framework];
	[self _searchTokenClusters:tokenClusters inFrameworkTopic:frameworkTopic];
}

- (void)_searchTokenClusters:(NSArray *)tokenClusters
			inFrameworkTopic:(AKFrameworkTopic *)frameworkTopic
{
	for (AKNamedObjectCluster *cluster in tokenClusters) {
		[self _searchTokenCluster:cluster inFrameworkTopic:frameworkTopic];
	}
}

- (void)_searchTokenCluster:(AKNamedObjectCluster *)tokenCluster
		   inFrameworkTopic:(AKFrameworkTopic *)frameworkTopic
{
	for (AKNamedObjectGroup *tokenGroup in tokenCluster.sortedGroups) {
		for (AKToken *token in tokenGroup.sortedObjects) {
			if ([self _matchesToken:token]) {
				[self.searchResults addObject:[AKDocLocator withTopic:frameworkTopic
														 subtopicName:tokenGroup.name
															  docName:token.name]];
			}
		}
	}
}

@end
