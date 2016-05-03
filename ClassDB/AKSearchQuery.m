/*
 * AKSearchQuery.m
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSearchQuery.h"

#import "DIGSLog.h"

#import "AKClassItem.h"
#import "AKClassTopic.h"
#import "AKDatabase.h"
#import "AKDocLocator.h"
#import "AKFunctionsTopic.h"
#import "AKGlobalsItem.h"
#import "AKGlobalsTopic.h"
#import "AKGroupItem.h"
#import "AKMethodItem.h"
#import "AKProtocolItem.h"
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
        if (_includesGlobals) [self _searchNamesOfGlobals];

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

- (BOOL)_matchesItem:(AKTokenItem *)tokenItem
{
    return [self _matchesString:tokenItem.tokenName];
}

- (void)_searchClassNames
{
    for (AKClassItem *classItem in [_database allClasses])
    {
        if ([self _matchesItem:classItem])
        {
            AKClassTopic *topic = [AKClassTopic topicWithClassItem:classItem];

            [_searchResults addObject:[AKDocLocator withTopic:topic subtopicName:nil docName:nil]];
        }
    }
}

- (void)_searchProtocolNames
{
    for (AKProtocolItem *protocolItem in [_database allProtocols])
    {
        if ([self _matchesItem:protocolItem])
        {
            AKProtocolTopic *topic = [AKProtocolTopic topicWithProtocolItem:protocolItem];

            [_searchResults addObject:[AKDocLocator withTopic:topic subtopicName:nil docName:nil]];
        }
    }
}

- (void)_searchNamesOfClassMembers
{
    for (AKClassItem *classItem in [_database allClasses])
    {
        AKClassTopic *topic = [AKClassTopic topicWithClassItem:classItem];

        // Search members common to all behaviors.
        [self _searchMembersUnderBehaviorTopic:topic];

        // Search members specific to classes.
        [self _searchTokenItems:[classItem documentedDelegateMethods]
             underSubtopic:AKDelegateMethodsSubtopicName
           ofBehaviorTopic:topic];
        [self _searchTokenItems:[classItem documentedNotifications]
             underSubtopic:AKNotificationsSubtopicName
           ofBehaviorTopic:topic];
    }
}

- (void)_searchNamesOfProtocolMembers
{
    for (AKProtocolItem *protocolItem in [_database allProtocols])
    {
        AKProtocolTopic *topic = [AKProtocolTopic topicWithProtocolItem:protocolItem];

        [self _searchMembersUnderBehaviorTopic:topic];
    }
}

- (void)_searchMembersUnderBehaviorTopic:(AKBehaviorTopic *)behaviorTopic
{
    AKBehaviorItem *behaviorItem = (AKBehaviorItem *)[behaviorTopic topicItem];

    // Search the behavior's properties.
    [self _searchTokenItems:[behaviorItem propertyItems]
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
            [self _searchTokenItems:[behaviorItem propertyItems]
                 underSubtopic:AKPropertiesSubtopicName
               ofBehaviorTopic:behaviorTopic];
        }}
        _searchString = savedSearchString;
    }

    // Search the behavior's class methods.
    [self _searchTokenItems:[behaviorItem documentedClassMethods]
         underSubtopic:AKClassMethodsSubtopicName
       ofBehaviorTopic:behaviorTopic];

    // Search the behavior's instance methods.
    [self _searchTokenItems:[behaviorItem instanceMethodItems]
         underSubtopic:AKInstanceMethodsSubtopicName
       ofBehaviorTopic:behaviorTopic];
}

// Search the functions in each of the function groups for each framework.
- (void)_searchFunctionNames
{
    for (NSString *fwName in [_database frameworkNames])
    {
        for (AKGroupItem *groupItem in [_database functionsGroupsForFrameworkNamed:fwName])
        {
            for (AKTokenItem *subitem in [groupItem subitems])
            {
                if ([self _matchesItem:subitem])
                {
                    AKTopic *topic = [AKFunctionsTopic topicWithFrameworkNamed:fwName
                                                                    inDatabase:_database];
                    [_searchResults addObject:[AKDocLocator withTopic:topic
                                                         subtopicName:groupItem.tokenName
                                                              docName:subitem.tokenName]];
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
        for (AKGroupItem *groupItem in [_database globalsGroupsForFrameworkNamed:fwName])
        {
            for (AKGlobalsItem *subitem in [groupItem subitems])
            {
                BOOL matchFound = NO;

//TODO: ak_stripHTML is too expensive -- bogging down the search
//TODO: I don't think we actually need to strip any HTML -- no token name seems to contain & or <
//                if ([self _matchesString:[[subitem tokenName] ak_stripHTML]])
                if ([self _matchesItem:subitem])
                {
                    matchFound = YES;
                }
                else
                {
                    for (NSString *globalName in [subitem namesOfGlobals])
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
                                                         subtopicName:groupItem.tokenName
                                                              docName:subitem.tokenName]];
                }
            }
        }
    }
}

- (void)_searchTokenItems:(NSArray *)itemArray
         underSubtopic:(NSString *)subtopicName
     ofBehaviorTopic:(AKBehaviorTopic *)topic
{
    for (AKTokenItem *item in itemArray)
    {
        if ([self _matchesItem:item])
        {
            [_searchResults addObject:[AKDocLocator withTopic:topic
                                                 subtopicName:subtopicName
                                                      docName:item.tokenName]];
        }
    }
}

@end
