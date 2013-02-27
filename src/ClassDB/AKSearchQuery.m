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

@interface AKSearchQuery ()
@property (nonatomic, retain) NSArray *searchResults;
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

#pragma mark -
#pragma mark Factory methods

+ (id)withDatabase:(AKDatabase *)db
{
    return [[[self alloc] initWithDatabase:db] autorelease];
}

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

        _searchResults = [[NSMutableArray alloc] init];
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
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

    // Set the ivar.
    [_searchString autorelease];
    _searchString = [s copy];

    // Update other ivars.
    _rangeForEntireSearchString = NSMakeRange(0, [s length]);
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

#pragma mark -
#pragma mark Searching

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
        [self setSearchResults:[NSMutableArray array]];

        if ([_searchString length] == 0)
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
        if (_includesGlobals) [self _searchNamesOfGlobals];

        // Sort the results.
        [AKDocLocator sortArrayOfDocLocators:_searchResults];
    }

    return _searchResults;
}

#pragma mark -
#pragma mark Private methods

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
                return (([s length] >= _rangeForEntireSearchString.length)
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

- (BOOL)_matchesNode:(AKDatabaseNode *)node
{
    return [self _matchesString:[node nodeName]];
}

- (void)_searchClassNames
{
    for (AKClassNode *classNode in [_database allClasses])
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
    for (AKProtocolNode *protocolNode in [_database allProtocols])
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
    for (AKClassNode *classNode in [_database allClasses])
    {
        AKClassTopic *topic = [AKClassTopic topicWithClassNode:classNode];

        // Search the class's properties.
        [self _searchNodes:[classNode documentedProperties]
               forSubtopic:AKPropertiesSubtopicName
           ofBehaviorTopic:topic];

        // Search the class's class methods.
        [self _searchNodes:[classNode documentedClassMethods]
               forSubtopic:AKClassMethodsSubtopicName
           ofBehaviorTopic:topic];

        // Search the class's instance methods.
        [self _searchNodes:[classNode documentedInstanceMethods]
               forSubtopic:AKInstanceMethodsSubtopicName
           ofBehaviorTopic:topic];

        // Search the class's delegate methods.
        [self _searchNodes:[classNode documentedDelegateMethods]
               forSubtopic:AKDelegateMethodsSubtopicName
           ofBehaviorTopic:topic];

        // Search the class's notifications.
        [self _searchNodes:[classNode documentedNotifications]
               forSubtopic:AKNotificationsSubtopicName
           ofBehaviorTopic:topic];
    }
}

- (void)_searchNamesOfProtocolMembers
{
    for (AKProtocolNode *protocolNode in [_database allProtocols])
    {
        AKProtocolTopic *topic = [AKProtocolTopic topicWithProtocolNode:protocolNode];

        // Search the protocol's properties.
        [self _searchNodes:[protocolNode documentedProperties]
               forSubtopic:AKPropertiesSubtopicName
           ofBehaviorTopic:topic];

        // Search the protocol's class methods.
        [self _searchNodes:[protocolNode documentedClassMethods]
               forSubtopic:AKClassMethodsSubtopicName
           ofBehaviorTopic:topic];

        // Search the protocol's instance methods.
        [self _searchNodes:[protocolNode documentedInstanceMethods]
               forSubtopic:AKInstanceMethodsSubtopicName
           ofBehaviorTopic:topic];
    }
}

// Search the functions in each of the function groups for each framework.
- (void)_searchFunctionNames
{
    for (NSString *fwName in [_database frameworkNames])
    {
        for (AKGroupNode *groupNode in [_database functionsGroupsForFrameworkNamed:fwName])
        {
            for (AKDatabaseNode *subnode in [groupNode subnodes])
            {
                if ([self _matchesNode:subnode])
                {
                    AKTopic *topic = [AKFunctionsTopic topicWithFrameworkNamed:fwName
                                                                    inDatabase:_database];
                    [_searchResults addObject:[AKDocLocator withTopic:topic
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
    for (NSString *fwName in [_database frameworkNames])
    {
        for (AKGroupNode *groupNode in [_database globalsGroupsForFrameworkNamed:fwName])
        {
            for (AKGlobalsNode *subnode in [groupNode subnodes])
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
                    for (NSString *globalName in [subnode namesOfGlobals])
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
                    AKTopic *topic = [AKGlobalsTopic topicWithFrameworkNamed:fwName
                                                                  inDatabase:_database];
                    [_searchResults addObject:[AKDocLocator withTopic:topic
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
    for (AKDatabaseNode *node in nodeArray)
    {
        if ([self _matchesNode:node])
        {
            [_searchResults addObject:[AKDocLocator withTopic:topic
                                                 subtopicName:subtopicName
                                                      docName:[node nodeName]]];
        }
    }
}

@end
