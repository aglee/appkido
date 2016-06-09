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
#import "AKFrameworkTokenClusterTopic.h"
#import "AKMethodToken.h"
#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"
#import "AKProtocolToken.h"
#import "AKProtocolTopic.h"
#import "AKSubtopic.h"
#import "AKToken.h"
#import "NSString+AppKiDo.h"

@interface AKSearchQuery ()
@property (nonatomic, strong) AKDatabase *database;
@property (nonatomic, copy) NSString *searchString;
// Only used during search, then reset to nil.  Made this strong rather than
// copy because we modify the array in place in a bunch of places, so we want
// the self-same NSMutableArray every time -- a copy won't do.  Copy wouldn't
// work anyway, because it causes the getter to return an immutable NSArray.
// The resulting exception on my attempt to modify the array was how I realized
// that copy doesn't work.
@property (nonatomic, strong) NSMutableArray *tempSearchResults;
@end


@implementation AKSearchQuery

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDatabase:(AKDatabase *)database
{
	NSParameterAssert(database != nil);
	self = [super init];
	if (self) {
		_database = database;
		_searchString = nil;
		_includesClassesAndProtocols = YES;
		_includesMembers = YES;
		_includesFunctionsAndGlobals = YES;
		_ignoresCase = YES;
		_searchComparison = AKSearchForSubstring;
		_tempSearchResults = [[NSMutableArray alloc] init];
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithDatabase:nil];
}

#pragma mark - Searching

- (NSArray *)doSearchForString:(NSString *)searchString
{
	self.searchString = searchString;
	[self _performSearch];
	NSArray *results = self.tempSearchResults;
	self.tempSearchResults = nil;
	return results;
}

- (void)includeEverythingInSearch
{
	self.includesClassesAndProtocols = YES;
	self.includesMembers = YES;
	self.includesFunctionsAndGlobals = YES;
}

#pragma mark - Private methods - general

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

- (void)_performSearch
{
	self.tempSearchResults = [NSMutableArray array];

	if (self.searchString.length == 0) {
		return;
	}

	// Each of the following calls appends its results to searchResults.
	[self _searchFrameworks];
	if (self.includesClassesAndProtocols) {
		[self _searchClasses];
		[self _searchProtocols];
	}
	if (self.includesMembers) {
		[self _searchClassMembers];
		[self _searchProtocolMembers];
	}
	if (self.includesFunctionsAndGlobals) {
		[self _searchFunctionsAndGlobals];
	}

	// Sort the results.
	[AKDocLocator sortArrayOfDocLocators:self.tempSearchResults];
}

#pragma mark - Private methods - searching frameworks

- (void)_searchFrameworks
{
	for (AKFramework *framework in self.database.frameworks) {
		if ([self _matchesString:framework.name]) 	{
			AKFrameworkTopic *topic = [[AKFrameworkTopic alloc] initWithFramework:framework];
			[self.tempSearchResults addObject:[[AKDocLocator alloc] initWithTopic:topic
																	 subtopicName:nil
																		  docName:nil]];
		}
	}
}

#pragma mark - Private methods - searching behaviors and their members

- (void)_searchClasses
{
	for (AKClassToken *classToken in self.database.allClassTokens) {
		if ([self _matchesString:classToken.name]) 	{
			AKClassTopic *topic = [[AKClassTopic alloc] initWithClassToken:classToken];
			[self.tempSearchResults addObject:[[AKDocLocator alloc] initWithTopic:topic
																	 subtopicName:nil
																		  docName:nil]];
		}
	}
}

- (void)_searchProtocols
{
	for (AKProtocolToken *protocolToken in self.database.allProtocolTokens) {
		if ([self _matchesString:protocolToken.name]) {
			AKProtocolTopic *topic = [[AKProtocolTopic alloc] initWithProtocolToken:protocolToken];
			[self.tempSearchResults addObject:[[AKDocLocator alloc] initWithTopic:topic
																	 subtopicName:nil
																		  docName:nil]];
		}
	}
}

- (void)_searchClassMembers
{
	for (AKClassToken *classToken in self.database.allClassTokens) {
		AKClassTopic *topic = [[AKClassTopic alloc] initWithClassToken:classToken];

		// Search members common to all behaviors.
		[self _searchMembersUnderBehaviorTopic:topic];

		// Search members specific to classes.
		[self _searchTokens:classToken.bindingTokens
			  underSubtopic:AKBindingsSubtopicName
			ofBehaviorTopic:topic];
	}
}

- (void)_searchProtocolMembers
{
	for (AKProtocolToken *protocolToken in self.database.allProtocolTokens) {
		AKProtocolTopic *topic = [[AKProtocolTopic alloc] initWithProtocolToken:protocolToken];
		[self _searchMembersUnderBehaviorTopic:topic];
	}
}

// Note that delegate methods are already searched for via the protocols they
// belong to, so we don't have to search for them here.
- (void)_searchMembersUnderBehaviorTopic:(AKBehaviorTopic *)behaviorTopic
{
	AKBehaviorToken *behaviorToken = (AKBehaviorToken *)[behaviorTopic topicToken];

	// Search the behavior's properties.
	[self _searchTokens:behaviorToken.propertyTokens
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
			[self _searchTokens:behaviorToken.propertyTokens
				  underSubtopic:AKPropertiesSubtopicName
				ofBehaviorTopic:behaviorTopic];
		}}
		_searchString = savedSearchString;
	}

	// Search the behavior's class methods.
	[self _searchTokens:behaviorToken.classMethodTokens
		  underSubtopic:AKClassMethodsSubtopicName
		ofBehaviorTopic:behaviorTopic];

	// Search the behavior's instance methods.
	[self _searchTokens:behaviorToken.instanceMethodTokens
		  underSubtopic:AKInstanceMethodsSubtopicName
		ofBehaviorTopic:behaviorTopic];

	// Search the behavior's data types.
	[self _searchTokens:behaviorToken.dataTypeTokens
		  underSubtopic:AKDataTypesSubtopicName
		ofBehaviorTopic:behaviorTopic];

	// Search the behavior's constants.
	[self _searchTokens:behaviorToken.constantTokens
		  underSubtopic:AKConstantsSubtopicName
		ofBehaviorTopic:behaviorTopic];

	// Search the behavior's notifications.
	[self _searchTokens:behaviorToken.notificationTokens
		  underSubtopic:AKNotificationsSubtopicName
		ofBehaviorTopic:behaviorTopic];
}

- (void)_searchTokens:(NSArray *)tokenArray
		underSubtopic:(NSString *)subtopicName
	  ofBehaviorTopic:(AKBehaviorTopic *)topic
{
	for (AKToken *token in tokenArray) {
		if ([self _matchesString:token.name]) {
			[self.tempSearchResults addObject:[[AKDocLocator alloc] initWithTopic:topic
																	 subtopicName:subtopicName
																		  docName:token.name]];
		}
	}
}

#pragma mark - Private methods - searching token clusters with AKFramework

- (void)_searchFunctionsAndGlobals
{
	for (AKFramework *framework in self.database.frameworks) {
		[self _searchFunctionsAndGlobalsInFramework:framework];
	}
}

- (void)_searchFunctionsAndGlobalsInFramework:(AKFramework *)framework
{
	AKFrameworkTopic *frameworkTopic = [[AKFrameworkTopic alloc] initWithFramework:framework];
	[self _searchTokenClusterChildTopicsWithNames:@[ AKFunctionsAndGlobalsTopicName ]
							  underFrameworkTopic:frameworkTopic ];
}

- (void)_searchTokenClusterChildTopicsWithNames:(NSArray *)childTopicNames
							underFrameworkTopic:(AKFrameworkTopic *)frameworkTopic
{
	for (NSString *childTopicName in childTopicNames) {
		AKTopic *childTopic = [frameworkTopic childTopicWithName:childTopicName];
		NSAssert(childTopic == nil
				 || [childTopic isKindOfClass:AKFrameworkTokenClusterTopic.class],
				 @"Child topic %@ of framework topic %@ is not a %@",
				 childTopic, frameworkTopic, AKFrameworkTokenClusterTopic.class);
		[self _searchFrameworkTokenClusterTopic:(AKFrameworkTokenClusterTopic *)childTopic];
	}
}

- (void)_searchFrameworkTokenClusterTopic:(AKFrameworkTokenClusterTopic *)tokenClusterTopic
{
	for (AKSubtopic *subtopic in tokenClusterTopic.subtopics) {
		for (id<AKDoc> doc in subtopic.docListItems) {
			if ([self _matchesString:doc.name]) {
				[self.tempSearchResults addObject:[[AKDocLocator alloc] initWithTopic:tokenClusterTopic
																		 subtopicName:subtopic.name
																			  docName:doc.name]];
			}
		}
	}
}

@end
