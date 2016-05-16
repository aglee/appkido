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
#import "AKFunctionsTopic.h"
#import "AKGlobalsTopic.h"
#import "AKGroupItem.h"
#import "AKMethodToken.h"
#import "AKProtocolToken.h"
#import "AKProtocolTopic.h"
#import "AKSortUtils.h"
#import "AKSubtopic.h"
#import "NSString+AppKiDo.h"

@interface AKSearchQuery ()
@property (nonatomic, strong) NSArray *searchResults;
@end

@implementation AKSearchQuery

@dynamic searchString;
@dynamic rangeForEntireSearchString;
@dynamic includesClassesAndProtocols;
@dynamic includesMembers;
@dynamic includesFunctions;
@dynamic includesGlobals;
@dynamic ignoresCase;
@dynamic searchComparison;
@synthesize searchResults = _searchResults;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDatabase:(AKDatabase *)db
{
    if ((self = [super init]))
    {
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

- (void)setSearchString:(NSString *)s
{
    if ((_searchString == s) || [_searchString isEqualToString:s])
    {
        return;
    }

    // Set the ivar.
    _searchString = [s copy];

    // Update other ivars.
    _rangeForEntireSearchString = NSMakeRange(0, s.length);
    [self setSearchResults:nil];
}

- (BOOL)includesClassesAndProtocols
{
    return _includesClassesAndProtocols;
}

- (void)setIncludesClassesAndProtocols:(BOOL)flag
{
    if (_includesClassesAndProtocols != flag)
    {
        _includesClassesAndProtocols = flag;
        [self setSearchResults:nil];
    }
}

- (BOOL)includesMembers
{
    return _includesMembers;
}

- (void)setIncludesMembers:(BOOL)flag
{
    if (_includesMembers != flag)
    {
        _includesMembers = flag;
        [self setSearchResults:nil];
    }
}

- (BOOL)includesFunctions
{
    return _includesFunctions;
}

- (void)setIncludesFunctions:(BOOL)flag
{
    if (_includesFunctions != flag)
    {
        _includesFunctions = flag;
        [self setSearchResults:nil];
    }
}

- (BOOL)includesGlobals
{
    return _includesGlobals;
}

- (void)setIncludesGlobals:(BOOL)flag
{
    if (_includesGlobals != flag)
    {
        _includesGlobals = flag;
        [self setSearchResults:nil];
    }
}

- (BOOL)ignoresCase
{
    return _ignoresCase;
}

- (void)setIgnoresCase:(BOOL)flag
{
    if (_ignoresCase != flag)
    {
        _ignoresCase = flag;
        [self setSearchResults:nil];
    }
}

- (AKSearchComparison)searchComparison
{
    return _searchComparison;
}

- (void)setSearchComparison:(AKSearchComparison)searchComparison
{
    if (_searchComparison != searchComparison)
    {
        _searchComparison = searchComparison;
        [self setSearchResults:nil];
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

- (NSArray *)queryResults
{
    if (_searchResults == nil)
    {
        self.searchResults = [NSMutableArray array];

        if (_searchString.length == 0)
        {
            return _searchResults;
        }

        // Search the various types of API constructs that we know about.
        // Each of the following calls appends its results to _searchResults.
        if (_includesClassesAndProtocols) [self _searchClassNames];
        if (_includesClassesAndProtocols) [self _searchProtocolNames];
        if (_includesMembers) [self _searchNamesOfClassMembers];
        if (_includesMembers) [self _searchNamesOfProtocolMembers];
        if (_includesFunctions) [self _searchFunctionNames];

        // Sort the results.
        [AKDocLocator sortArrayOfDocLocators:_searchResults];
    }

    return _searchResults;
}

#pragma mark - Private methods

- (BOOL)_matchesString:(NSString *)s
{
    switch (_searchComparison)
    {
        case AKSearchForSubstring:
        {
            return (_ignoresCase
                    ? [s ak_containsCaseInsensitive:_searchString]
                    : [s ak_contains:_searchString]);
        }

        case AKSearchForExactMatch:
        {
            return (_ignoresCase
                    ? ([s compare:_searchString options:NSCaseInsensitiveSearch] == 0)
                    : [s isEqualToString:_searchString]);
        }

        case AKSearchForPrefix:
        {
            if (_ignoresCase)
            {
                return ((s.length >= _rangeForEntireSearchString.length)
                        && ([s compare:_searchString
                               options:NSCaseInsensitiveSearch
                                 range:_rangeForEntireSearchString] == 0));
            }
            else
            {
                return [s hasPrefix:_searchString];
            }
        }

        default:
        {
            DIGSLogDebug(@"Unexpected search comparison mode %d", _searchComparison);
            return NO;
        }
    }
}

- (BOOL)_matchesItem:(AKToken *)token
{
    return [self _matchesString:token.name];
}

- (void)_searchClassNames
{
    for (AKClassToken *classToken in [_database allClasses])
    {
        if ([self _matchesItem:classToken])
        {
            AKClassTopic *topic = [[AKClassTopic alloc] initWithClassToken:classToken];

            [_searchResults addObject:[AKDocLocator withTopic:topic subtopicName:nil docName:nil]];
        }
    }
}

- (void)_searchProtocolNames
{
    for (AKProtocolToken *protocolToken in [_database allProtocols])
    {
        if ([self _matchesItem:protocolToken])
        {
            AKProtocolTopic *topic = [[AKProtocolTopic alloc] initWithProtocolToken:protocolToken];

            [_searchResults addObject:[AKDocLocator withTopic:topic subtopicName:nil docName:nil]];
        }
    }
}

- (void)_searchNamesOfClassMembers
{
    for (AKClassToken *classToken in [_database allClasses])
    {
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

- (void)_searchNamesOfProtocolMembers
{
    for (AKProtocolToken *protocolToken in [_database allProtocols])
    {
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
    if ([_searchString.lowercaseString hasPrefix:@"set"]
        && _searchString.length > 3)
    {
        // Kludge to temporarily set _searchString to "XYZ".
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

// Search the functions in each of the function groups for each framework.
- (void)_searchFunctionNames
{
    for (NSString *fwName in [_database frameworkNames])
    {
        for (AKGroupItem *groupItem in [_database functionsGroupsForFramework:fwName])
        {
            for (AKToken *subitem in [groupItem subitems])
            {
                if ([self _matchesItem:subitem])
                {
                    AKTopic *topic = [[AKFunctionsTopic alloc] initWithFramework:fwName
                                                                        database:_database];
                    [_searchResults addObject:[AKDocLocator withTopic:topic
                                                         subtopicName:groupItem.name
                                                              docName:subitem.name]];
                }
            }
        }
    }
}

- (void)_searchTokens:(NSArray *)itemArray
         underSubtopic:(NSString *)subtopicName
     ofBehaviorTopic:(AKBehaviorTopic *)topic
{
    for (AKToken *item in itemArray)
    {
        if ([self _matchesItem:item])
        {
            [_searchResults addObject:[AKDocLocator withTopic:topic
                                                 subtopicName:subtopicName
                                                      docName:item.name]];
        }
    }
}

@end
