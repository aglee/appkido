/*
 * AKSearchQuery.m
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSearchQuery.h"

#import "DIGSLog.h"

#import "AKSortUtils.h"
#import "AKTextUtils.h"
#import "AKDatabase.h"
#import "AKClassNode.h"
#import "AKProtocolNode.h"
#import "AKMethodNode.h"
#import "AKGlobalsNode.h"
#import "AKGroupNode.h"
#import "AKFileSection.h"
#import "AKDocLocator.h"
#import "AKClassTopic.h"
#import "AKProtocolTopic.h"
#import "AKFunctionsTopic.h"
#import "AKGlobalsTopic.h"
#import "AKSubtopic.h"

// [agl] working on performance
#define MEASURE_SEARCH_SPEED 0



#pragma mark -
#pragma mark Forward declarations of private methods

@interface AKSearchQuery (Private)

- (void)_clearSearchResults;

- (BOOL)_matchesString:(NSString *)s;
- (BOOL)_matchesNode:(AKDatabaseNode *)node;

- (void)_searchClassNames;
- (void)_searchProtocolNames;
- (void)_searchNamesOfClassMembers;
- (void)_searchNamesOfProtocolMembers;
- (void)_searchFunctionNames;
- (void)_searchNamesOfGlobals;

- (void)_searchNodes:(NSArray *)nodeArray
    forSubtopic:(NSString *)subtopicName
    ofBehaviorTopic:(AKBehaviorTopic *)topic;

@end


@implementation AKSearchQuery


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithDatabase:(AKDatabase *)db
{
    if ((self = [super init]))
    {
        _database = [db retain];

        _searchString = nil;

        _includesClassesAndProtocols = YES;
        _includesMembers = YES;
        _includesFunctions = YES;
        _includesGlobals = YES;
        _ignoresCase = YES;
        _searchComparison = AKSearchForSubstring;

        _searchResults = [[NSMutableArray array] retain];
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    [self release];
    return nil;
}

- (void)dealloc
{
    [_database release];
    [_searchString release];

    [_searchResults release];

    [super dealloc];
}


#pragma mark -
#pragma mark Getters and setters

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

    // Update the _searchString ivar.
    [s retain];
    [_searchString release];
    _searchString = s;

    // Update other ivars.
    _rangeForEntireSearchString = NSMakeRange(0, [s length]);
    [self _clearSearchResults];
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
        [self _clearSearchResults];
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
        [self _clearSearchResults];
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
        [self _clearSearchResults];
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
        [self _clearSearchResults];
    }
}

- (void)setIncludesEverything
{
    [self setIncludesClassesAndProtocols:YES];
    [self setIncludesMembers:YES];
    [self setIncludesFunctions:YES];
    [self setIncludesGlobals:YES];
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
        [self _clearSearchResults];
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
        [self _clearSearchResults];
    }
}


#pragma mark -
#pragma mark Searching


// [agl] working on performance
#if MEASURE_SEARCH_SPEED
static int g_NSStringComparisons = 0;
static NSTimeInterval g_startTime = 0.0;
static NSTimeInterval g_checkpointTime = 0.0;

- (void)_timeSearchStart
{
    g_NSStringComparisons = 0;
    g_startTime = [NSDate timeIntervalSinceReferenceDate];
    g_checkpointTime = g_startTime;
    NSLog(@"---------------------------------");
    NSLog(@"START: searching for [%@]...", _searchString);
}

- (void)_timeSearchCheckpoint:(NSString *)description
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"...CHECKPOINT: %@", description);
    NSLog(@"               compared %d strings", g_NSStringComparisons);
    NSLog(@"               %.3f seconds since last checkpoint",
        now - g_checkpointTime);
    g_checkpointTime = now;
}

- (void)_timeSearchEnd
{
    NSLog(@"...DONE: got %d results, took %.3f seconds total",
        [_searchResults count],
        [NSDate timeIntervalSinceReferenceDate] - g_startTime);
}
#endif MEASURE_SEARCH_SPEED


- (NSArray *)queryResults
{
    if (_searchResults == nil)
    {

// [agl] working on performance
#if MEASURE_SEARCH_SPEED
[self _timeSearchStart];
#endif MEASURE_SEARCH_SPEED

        _searchResults = [[NSMutableArray alloc] init];

        if ((_searchString == nil) || ([_searchString length] == 0))
        {
            // Note that it's safe to return _searchResults here, because
            // it's retained.
            return _searchResults;
        }

        // Search the various types of API constructs that we know about.
        // Each of the following calls appends its results to _searchResults.
        if (_includesClassesAndProtocols) [self _searchClassNames];
        if (_includesClassesAndProtocols) [self _searchProtocolNames];
        if (_includesMembers) [self _searchNamesOfClassMembers];
        if (_includesMembers) [self _searchNamesOfProtocolMembers];
        if (_includesFunctions) [self _searchFunctionNames];
        if (_includesGlobals) [self _searchNamesOfGlobals];

// [agl] working on performance
#if MEASURE_SEARCH_SPEED
[self _timeSearchCheckpoint:@"about to sort..."];
#endif MEASURE_SEARCH_SPEED

        // Sort the results.
        [AKDocLocator sortArrayOfDocLocators:_searchResults];

// [agl] working on performance
#if MEASURE_SEARCH_SPEED
[self _timeSearchEnd];
#endif MEASURE_SEARCH_SPEED
    }

    return _searchResults;
}

@end



#pragma mark -
#pragma mark Private methods

@implementation AKSearchQuery (Private)

- (void)_clearSearchResults
{
    [_searchResults release];
    _searchResults = nil;
}

- (BOOL)_matchesString:(NSString *)s
{
// [agl] working on performance
#if MEASURE_SEARCH_SPEED
g_NSStringComparisons++;
#endif MEASURE_SEARCH_SPEED

//DIGSLogDebug(@"[%@] (%@)", _searchString, s);  // [agl] REMOVE

    switch (_searchComparison)
    {
        case AKSearchForSubstring: {
            return
                _ignoresCase
                ? [s ak_containsCaseInsensitive:_searchString]
                : [s ak_contains:_searchString];
        }

        case AKSearchForExactMatch: {
            return
                _ignoresCase
                ? ([s compare:_searchString options:NSCaseInsensitiveSearch] == 0)
                : [s isEqualToString:_searchString];
        }

        case AKSearchForPrefix: {
            if (_ignoresCase)
            {
                return
                    ([s length] >= _rangeForEntireSearchString.length)
                    &&
                    ([s
                        compare:_searchString
                        options:NSCaseInsensitiveSearch
                        range:_rangeForEntireSearchString] == 0);
            }
            else
            {
                return [s hasPrefix:_searchString];
            }
        }

        default: {
            DIGSLogDebug(@"Unexpected search comparison mode %d",
                _searchComparison);
            return NO;
        }
    }
}

- (BOOL)_matchesNode:(AKDatabaseNode *)node
{
    return [self _matchesString:[node nodeName]];
}

- (void)_searchClassNames
{
    NSEnumerator *en = [[_database allClasses] objectEnumerator];
    AKClassNode *classNode;

    while ((classNode = [en nextObject]))
    {
        if ([self _matchesNode:classNode])
        {
            AKClassTopic *topic = [AKClassTopic topicWithClassNode:classNode];

            [_searchResults addObject:[AKDocLocator withTopic:topic subtopicName:nil docName:nil]];
        }
    }
}

- (void)_searchProtocolNames
{
    NSEnumerator *en = [[_database allProtocols] objectEnumerator];
    AKProtocolNode *protocolNode;

    while ((protocolNode = [en nextObject]))
    {
        if ([self _matchesNode:protocolNode])
        {
            AKProtocolTopic *topic = [AKProtocolTopic topicWithProtocolNode:protocolNode];

            [_searchResults addObject:[AKDocLocator withTopic:topic subtopicName:nil docName:nil]];
        }
    }
}

- (void)_searchNamesOfClassMembers
{
    NSEnumerator *en = [[_database allClasses] objectEnumerator];
    AKClassNode *classNode;

    while ((classNode = [en nextObject]))
    {
        AKClassTopic *topic = [AKClassTopic topicWithClassNode:classNode];

        // Search the class's properties.
        [self
            _searchNodes:[classNode documentedProperties]
            forSubtopic:AKPropertiesSubtopicName
            ofBehaviorTopic:topic];

        // Search the class's class methods.
        [self
            _searchNodes:[classNode documentedClassMethods]
            forSubtopic:AKClassMethodsSubtopicName
            ofBehaviorTopic:topic];

        // Search the class's instance methods.
        [self
            _searchNodes:[classNode documentedInstanceMethods]
            forSubtopic:AKInstanceMethodsSubtopicName
            ofBehaviorTopic:topic];

        // Search the class's delegate methods.
        [self
            _searchNodes:[classNode documentedDelegateMethods]
            forSubtopic:AKDelegateMethodsSubtopicName
            ofBehaviorTopic:topic];

        // Search the class's notifications.
        [self
            _searchNodes:[classNode documentedNotifications]
            forSubtopic:AKNotificationsSubtopicName
            ofBehaviorTopic:topic];
    }
}

- (void)_searchNamesOfProtocolMembers
{
    NSEnumerator *en = [[_database allProtocols] objectEnumerator];
    AKProtocolNode *protocolNode;

    while ((protocolNode = [en nextObject]))
    {
        AKProtocolTopic *topic =
            [AKProtocolTopic topicWithProtocolNode:protocolNode];

        // Search the protocol's properties.
        [self
            _searchNodes:[protocolNode documentedProperties]
            forSubtopic:AKPropertiesSubtopicName
            ofBehaviorTopic:topic];

        // Search the protocol's class methods.
        [self
            _searchNodes:[protocolNode documentedClassMethods]
            forSubtopic:AKClassMethodsSubtopicName
            ofBehaviorTopic:topic];

        // Search the protocol's instance methods.
        [self
            _searchNodes:[protocolNode documentedInstanceMethods]
            forSubtopic:AKInstanceMethodsSubtopicName
            ofBehaviorTopic:topic];
    }
}

// Search the functions in each of the function groups for each framework.
- (void)_searchFunctionNames
{
    NSEnumerator *fwNameEnum = [[_database frameworkNames] objectEnumerator];
    NSString *fwName;

    while ((fwName = [fwNameEnum nextObject]))
    {
        NSArray *functionGroups =
            [_database functionsGroupsForFrameworkNamed:fwName];
        NSEnumerator *groupEnum = [functionGroups objectEnumerator];
        AKGroupNode *groupNode;

        while ((groupNode = [groupEnum nextObject]))
        {
            NSEnumerator *subnodeEnum =
                [[groupNode subnodes] objectEnumerator];
            AKDatabaseNode *subnode;

            while ((subnode = [subnodeEnum nextObject]))
            {
                if ([self _matchesNode:subnode])
                {
                    AKTopic *topic = [AKFunctionsTopic topicWithFrameworkNamed:fwName inDatabase:_database];

                    [_searchResults
                        addObject:
                            [AKDocLocator
                                withTopic:topic
                                subtopicName:[groupNode nodeName]
                                docName:[subnode nodeName]]];
                }
            }
        }
    }
}

// Search the globals in each of the groups of globals for each framework.
- (void)_searchNamesOfGlobals
{
    NSEnumerator *fwNameEnum = [[_database frameworkNames] objectEnumerator];
    NSString *fwName;

    while ((fwName = [fwNameEnum nextObject]))
    {
        NSArray *globalsGroups =
            [_database globalsGroupsForFrameworkNamed:fwName];
        NSEnumerator *groupEnum = [globalsGroups objectEnumerator];
        AKGroupNode *groupNode;

        while ((groupNode = [groupEnum nextObject]))
        {
            NSEnumerator *subnodeEnum =
                [[groupNode subnodes] objectEnumerator];
            AKGlobalsNode *subnode;

            while ((subnode = [subnodeEnum nextObject]))
            {
                BOOL matchFound = NO;

// [agl] ak_stripHTML is too expensive -- bogging down the search
// [agl] I don't think we actually need to strip any HTML -- no node seems to contain & or <
//                if ([self _matchesString:[[subnode nodeName] ak_stripHTML]])
                if ([self _matchesNode:subnode])
                {
                    matchFound = YES;
                }
                else
                {
                    NSEnumerator *globalNameEnum =
                        [[subnode namesOfGlobals] objectEnumerator];
                    NSString *globalName;

                    while ((globalName = [globalNameEnum nextObject]))
                    {
                        if ([self _matchesString:globalName])
                        {
                            matchFound = YES;
                            break;
                        }
                    }
                }

                if (matchFound)
                {
                    AKTopic *topic =
                        [AKGlobalsTopic
                            topicWithFrameworkNamed:fwName
                            inDatabase:_database];

                    [_searchResults
                        addObject:
                            [AKDocLocator
                                withTopic:topic
                                subtopicName:[groupNode nodeName]
                                docName:[subnode nodeName]]];
                }
            }
        }
    }
}

- (void)_searchNodes:(NSArray *)nodeArray
    forSubtopic:(NSString *)subtopicName
    ofBehaviorTopic:(AKBehaviorTopic *)topic
{
    NSEnumerator *nodeEnum = [nodeArray objectEnumerator];
    AKDatabaseNode *node;

    while ((node = [nodeEnum nextObject]))
    {
        if ([self _matchesNode:node])
        {
            [_searchResults
                addObject:
                    [AKDocLocator
                        withTopic:topic
                        subtopicName:subtopicName
                        docName:[node nodeName]]];
        }
    }
}

@end


