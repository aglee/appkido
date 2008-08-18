/*
 * AKDatabase.m
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDatabase.h"

#import "DIGSLog.h"

#import "AKPrefUtils.h"

#import "AKClassNode.h"
#import "AKProtocolNode.h"
#import "AKGroupNode.h"

#import "AKDocSetIndex.h"
#import "AKOldDatabase.h"
#import "AKDatabaseWithDocSet.h"


@interface AKDatabase (Private)
- (void)_seeIfFrameworkIsNew:(NSString *)fwName;
- (NSArray *)_allProtocolsForFramework:(NSString *)fwName;
@end


@implementation AKDatabase

//-------------------------------------------------------------------------
// Class methods
//-------------------------------------------------------------------------

+ (AKDatabase *)defaultDatabase  // [agl] REMOVE get rid of the global database; use individual instances
{
    static AKDatabase *s_defaultDatabase = nil;

    if (s_defaultDatabase == nil)
    {
BOOL isForIPhone = NO;  // [agl] REMOVE
if (isForIPhone)
{
        s_defaultDatabase = [[self databaseForLatestIPhoneSDK] retain];
}
else
{
        s_defaultDatabase = [[self databaseForMacSDK] retain];
}
    }

    return s_defaultDatabase;
}

+ (id)databaseForMacSDK
{
    return
        [self databaseForMacSDKInDevToolsPath:[AKPrefUtils devToolsPathPref]];
}

+ (id)databaseForLatestIPhoneSDK
{
    AKDocSetIndex *docSetIndex =
        [AKDocSetIndex
            indexForLatestIPhoneSDKInDevToolsPath:
                [AKPrefUtils devToolsPathPref]];

    return [self databaseWithDocSetIndex:docSetIndex];
}

+ (id)databaseForMacSDKInDevToolsPath:(NSString *)devToolsPath
{
    AKDocSetIndex *docSetIndex =
        [AKDocSetIndex indexForMacSDKInDevToolsPath:devToolsPath];

    if (docSetIndex)
    {
        return [self databaseWithDocSetIndex:docSetIndex];
    }
    else
    {
        return
            [[[AKOldDatabase alloc]
                initWithDevToolsPath:devToolsPath] autorelease];
    }
}

+ (id)databaseWithDocSetIndex:(AKDocSetIndex *)docSetIndex
{
    if (docSetIndex == nil)
    {
        return nil;
    }
    else
    {
        return
            [[[AKDatabaseWithDocSet alloc]
                initWithDocSetIndex:docSetIndex] autorelease];
    }
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)init
{
    if ((self = [super init]))
    {
        _frameworkNames = [[NSMutableArray alloc] init];
        _namesOfAvailableFrameworks = nil;

        _classNodesByName = [[NSMutableDictionary alloc] init];
        _classListsByFramework = [[NSMutableDictionary alloc] init];

        _protocolNodesByName = [[NSMutableDictionary alloc] init];
        _protocolListsByFramework = [[NSMutableDictionary alloc] init];

        _functionsGroupListsByFramework = [[NSMutableDictionary alloc] init];
        _functionsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

        _globalsGroupListsByFramework = [[NSMutableDictionary alloc] init];
        _globalsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

        _classNodesByHTMLPath = [[NSMutableDictionary alloc] init];
        _protocolNodesByHTMLPath = [[NSMutableDictionary alloc] init];
        _rootSectionsByHTMLPath = [[NSMutableDictionary alloc] init];
        _offsetsOfAnchorStringsInHTMLFiles =
            [[NSMutableDictionary alloc] initWithCapacity:30000];

        _nodesByHTMLPathAndTokenName = [[NSMutableDictionary alloc] init];
        _frameworkNamesByHTMLPath = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [_frameworkNames release];

    [_classNodesByName release];
    [_classListsByFramework release];

    [_protocolNodesByName release];
    [_protocolListsByFramework release];

    [_functionsGroupListsByFramework release];
    [_functionsGroupsByFrameworkAndGroup release];

    [_globalsGroupListsByFramework release];
    [_globalsGroupsByFrameworkAndGroup release];

    [_classNodesByHTMLPath release];
    [_protocolNodesByHTMLPath release];
    [_rootSectionsByHTMLPath release];
    [_offsetsOfAnchorStringsInHTMLFiles release];

    [_nodesByHTMLPathAndTokenName release];
    [_frameworkNamesByHTMLPath release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Populating
//-------------------------------------------------------------------------

- (void)loadTokensForFrameworks:(NSArray *)frameworkNames
{
    NSEnumerator *fwNameEnum = [frameworkNames objectEnumerator];
    NSString *fwName;

    while ((fwName = [fwNameEnum nextObject]))
    {
        DIGSLogDebug(@"===================================================");
        DIGSLogDebug(@"Loading tokens for framework %@", fwName);
        DIGSLogDebug(@"===================================================");

        if ([_delegate respondsToSelector:@selector(database:willLoadTokensForFramework:)])
        {
            [_delegate database:self willLoadTokensForFramework:fwName];
        }

        [self loadTokensForFrameworkNamed:fwName];
    }
}

- (void)loadTokensForFrameworkNamed:(NSString *)fwName
{
    DIGSLogMissingOverride();
}

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;  // note this is NOT retained
}

//-------------------------------------------------------------------------
// Getters and setters -- frameworks
//-------------------------------------------------------------------------

- (NSArray *)frameworkNames
{
    return _frameworkNames;
}

- (NSArray *)sortedFrameworkNames
{
    return [_frameworkNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (BOOL)hasFrameworkWithName:(NSString *)fwName
{
    return [_frameworkNames containsObject:fwName];
}

- (NSArray *)namesOfAvailableFrameworks
{
    return _namesOfAvailableFrameworks;
}

//-------------------------------------------------------------------------
// Getters and setters -- classes
//-------------------------------------------------------------------------

- (NSArray *)classesForFramework:(NSString *)fwName
{
    return [_classListsByFramework objectForKey:fwName];
}

- (NSArray *)rootClasses
{
    NSMutableArray *result = [NSMutableArray array];
    NSEnumerator *en;
    AKClassNode *classNode;

    en = [_classNodesByName objectEnumerator];
    while ((classNode = [en nextObject]))
    {
        if ([classNode parentClass] == nil)
        {
            [result addObject:classNode];
        }
    }

    return result;
}

- (NSArray *)allClasses
{
    return [_classNodesByName allValues];
}

- (AKClassNode *)classWithName:(NSString *)name
{
    return [_classNodesByName objectForKey:name];
}

- (void)addClassNode:(AKClassNode *)classNode
{
    // Do nothing if we already have a class with the same name.
    NSString *className = [classNode nodeName];
    if ([_classNodesByName objectForKey:className])
    {
        DIGSLogDebug(@"Trying to add class [%@] again", className);
        return;
    }

    // Add the class to our lookup by class name.
    [_classNodesByName setObject:classNode forKey:className];

    // Add the class to our lookup by framework name.
    NSString *fwName = [classNode owningFramework];
    NSMutableArray *classNodes = [_classListsByFramework objectForKey:fwName];

    if (classNodes == nil)
    {
        classNodes = [NSMutableArray array];
        [_classListsByFramework setObject:classNodes forKey:fwName];
    }

    [classNodes addObject:classNode];

    // Add the framework to our framework list if it's not there already.
    [self _seeIfFrameworkIsNew:fwName];
}

//-------------------------------------------------------------------------
// Getters and setters -- protocols
//-------------------------------------------------------------------------

- (NSArray *)formalProtocolsForFramework:(NSString *)fwName
{
    NSMutableArray *result = [NSMutableArray array];
    NSEnumerator *en = [[self _allProtocolsForFramework:fwName] objectEnumerator];
    AKProtocolNode *protocolNode;

    while ((protocolNode = [en nextObject]))
    {
        if (![protocolNode isInformal])
        {
            [result addObject:protocolNode];
        }
    }

    return result;
}

- (NSArray *)informalProtocolsForFramework:(NSString *)fwName
{
    NSMutableArray *result = [NSMutableArray array];
    NSEnumerator *en = [[self _allProtocolsForFramework:fwName] objectEnumerator];
    AKProtocolNode *protocolNode;

    while ((protocolNode = [en nextObject]))
    {
        if ([protocolNode isInformal])
        {
            [result addObject:protocolNode];
        }
    }

    return result;
}

- (NSArray *)allProtocols
{
    return [_protocolNodesByName allValues];
}

- (AKProtocolNode *)protocolWithName:(NSString *)name
{
    return [_protocolNodesByName objectForKey:name];
}

- (void)addProtocolNode:(AKProtocolNode *)protocolNode
{
    // Do nothing if we already have a protocol with the same name.
    NSString *protocolName = [protocolNode nodeName];
    if ([_protocolNodesByName objectForKey:protocolName])
    {
        DIGSLogDebug(@"Trying to add protocol [%@] again", protocolName);
        return;
    }

    // Add the protocol to our lookup by protocol name.
    [_protocolNodesByName setObject:protocolNode forKey:protocolName];

    // Add the class to our lookup by framework name.
    NSString *fwName = [protocolNode owningFramework];
    NSMutableArray *protocolNodes = [_protocolListsByFramework objectForKey:fwName];

    if (protocolNodes == nil)
    {
        protocolNodes = [NSMutableArray array];
        [_protocolListsByFramework setObject:protocolNodes forKey:fwName];
    }

    [protocolNodes addObject:protocolNode];

    // Add the framework to our framework list if it's not there already.
    [self _seeIfFrameworkIsNew:fwName];
}

//-------------------------------------------------------------------------
// Getters and setters -- functions
//-------------------------------------------------------------------------

- (int)numberOfFunctionsGroupsForFramework:(NSString *)fwName
{
    return [[_functionsGroupListsByFramework objectForKey:fwName] count];
}

- (NSArray *)functionsGroupsForFramework:(NSString *)fwName
{
    return [_functionsGroupListsByFramework objectForKey:fwName];
}

- (AKGroupNode *)functionsGroupWithName:(NSString *)groupName
    inFramework:(NSString *)fwName
{
    return
        [[_functionsGroupsByFrameworkAndGroup objectForKey:fwName]
            objectForKey:groupName];
}

- (void)addFunctionsGroup:(AKGroupNode *)groupNode
{
    NSString *fwName = [groupNode owningFramework];

    // See if we have any functions groups in the framework yet.
    NSMutableArray *groupList = nil;
    NSMutableDictionary *groupsByName =
        [_functionsGroupsByFrameworkAndGroup objectForKey:fwName];

    if (groupsByName)
    {
        groupList = [_functionsGroupListsByFramework objectForKey:fwName];
    }
    else
    {
        groupsByName = [NSMutableDictionary dictionary];
        [_functionsGroupsByFrameworkAndGroup setObject:groupsByName forKey:fwName];

        groupList = [NSMutableArray array];
        [_functionsGroupListsByFramework setObject:groupList forKey:fwName];
    }

    // Add the functions group if it isn't already in the framework.
    NSString *groupName = [groupNode nodeName];

    if ([groupsByName objectForKey:groupName])
    {
        DIGSLogWarning(@"Trying to add functions group [%@] again", groupName);
    }
    else
    {
        [groupList addObject:groupNode];
        [groupsByName setObject:groupNode forKey:[groupNode nodeName]];
    }

    // Add the framework to our framework list if it's not there already.
    [self _seeIfFrameworkIsNew:fwName];
}

- (AKGroupNode *)functionsGroupContainingFunction:functionName
    inFramework:(NSString *)fwName
{
    // Get the functions groups for the given framework.
    NSMutableArray *groupList = [_functionsGroupListsByFramework objectForKey:fwName];
    if (groupList == nil)
    {
        return nil;
    }

    // Check each functions group to see if it contains the given function.
    NSEnumerator *groupListEnum = [groupList objectEnumerator];
    AKGroupNode *groupNode;

    while ((groupNode = [groupListEnum nextObject]))
    {
        if ([groupNode subnodeWithName:functionName] != nil)
        {
            return groupNode;
        }
    }

    // If we got this far, we couldn't find the function.
    return nil;
}

//-------------------------------------------------------------------------
// Getters and setters -- globals
//-------------------------------------------------------------------------

- (int)numberOfGlobalsGroupsForFramework:(NSString *)fwName
{
    return [[_globalsGroupListsByFramework objectForKey:fwName] count];
}

- (NSArray *)globalsGroupsForFramework:(NSString *)fwName
{
    return [_globalsGroupListsByFramework objectForKey:fwName];
}

- (AKGroupNode *)globalsGroupWithName:(NSString *)groupName
    inFramework:(NSString *)fwName
{
    return
        [[_globalsGroupsByFrameworkAndGroup objectForKey:fwName]
            objectForKey:groupName];
}

- (void)addGlobalsGroup:(AKGroupNode *)groupNode
{
    NSString *fwName = [groupNode owningFramework];

    // See if we have any globals groups in the framework yet.
    NSMutableArray *groupList = nil;
    NSMutableDictionary *groupsByName =
        [_globalsGroupsByFrameworkAndGroup objectForKey:fwName];

    if (groupsByName)
    {
        groupList = [_globalsGroupListsByFramework objectForKey:fwName];
    }
    else
    {
        groupsByName = [NSMutableDictionary dictionary];
        [_globalsGroupsByFrameworkAndGroup setObject:groupsByName forKey:fwName];

        groupList = [NSMutableArray array];
        [_globalsGroupListsByFramework setObject:groupList forKey:fwName];
    }

    // Add the globals group if it isn't already in the framework.
    NSString *groupName = [groupNode nodeName];

    if ([groupsByName objectForKey:groupName])
    {
        DIGSLogWarning(@"Trying to add globals group [%@] again", groupName);
    }
    else
    {
        [groupList addObject:groupNode];
        [groupsByName setObject:groupNode forKey:[groupNode nodeName]];
    }

    // Add the framework to our framework list if it's not there already.
    [self _seeIfFrameworkIsNew:fwName];
}

- (AKGroupNode *)globalsGroupContainingGlobal:nameOfGlobal
    inFramework:(NSString *)fwName
{
    // Get the globals groups for the given framework.
    NSMutableArray *groupList = [_globalsGroupListsByFramework objectForKey:fwName];
    if (groupList == nil)
    {
        return nil;
    }

    // Check each globals group to see if it contains the given global.
    NSEnumerator *groupListEnum = [groupList objectEnumerator];
    AKGroupNode *groupNode;

    while ((groupNode = [groupListEnum nextObject]))
    {
        if ([groupNode subnodeWithName:nameOfGlobal] != nil)
        {
            return groupNode;
        }
    }

    // If we got this far, we couldn't find the global.
    return nil;
}

//-------------------------------------------------------------------------
// Getters and setters -- DEPRECATED hyperlink support
//-------------------------------------------------------------------------

- (void)rememberFramework:(NSString *)frameworkName
    forHTMLFile:(NSString *)htmlFilePath
{
    [_frameworkNamesByHTMLPath setObject:frameworkName forKey:htmlFilePath];
}

- (AKClassNode *)classDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    return [_classNodesByHTMLPath objectForKey:htmlFilePath];
}

- (void)rememberThatClass:(AKClassNode *)classNode
    isDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    [_classNodesByHTMLPath setObject:classNode forKey:htmlFilePath];
}

- (AKProtocolNode *)protocolDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    return [_protocolNodesByHTMLPath objectForKey:htmlFilePath];
}

- (void)rememberThatProtocol:(AKProtocolNode *)protocolNode
    isDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    [_protocolNodesByHTMLPath setObject:protocolNode forKey:htmlFilePath];
}

- (AKFileSection *)rootSectionForHTMLFile:(NSString *)filePath
{
    return [_rootSectionsByHTMLPath objectForKey:filePath];
}

- (void)rememberRootSection:(AKFileSection *)rootSection
    forHTMLFile:(NSString *)filePath
{
    [_rootSectionsByHTMLPath setObject:rootSection forKey:filePath];
}

- (int)offsetOfAnchorString:(NSString *)anchorString
    inHTMLFile:(NSString *)filePath
{
    NSMutableDictionary *offsetsByFilePath =
        [_offsetsOfAnchorStringsInHTMLFiles objectForKey:anchorString];

    if (offsetsByFilePath == nil)
    {
        return -1;
    }

    NSNumber *offsetValue = [offsetsByFilePath objectForKey:filePath];

    if (offsetValue == nil)
    {
        return -1;
    }

    return [offsetValue intValue];
}

- (void)rememberOffset:(int)anchorOffset
    ofAnchorString:(NSString *)anchorString
    inHTMLFile:(NSString *)filePath
{
    NSMutableDictionary *offsetsByFilePath =
        [_offsetsOfAnchorStringsInHTMLFiles objectForKey:anchorString];

    if (offsetsByFilePath == nil)
    {
        offsetsByFilePath = [NSMutableDictionary dictionary];

        [_offsetsOfAnchorStringsInHTMLFiles
            setObject:offsetsByFilePath
            forKey:anchorString];
    }

    NSNumber *offsetValue = [NSNumber numberWithInt:anchorOffset];

    [offsetsByFilePath
        setObject:offsetValue
        forKey:filePath];
}

//-------------------------------------------------------------------------
// Getters and setters -- FUTURE hyperlink support
//-------------------------------------------------------------------------

- (AKDatabaseNode *)nodeForTokenName:(NSString *)tokenName
    inHTMLFile:(NSString *)htmlFilePath
{
    NSMutableArray *nodeList =
        [_nodesByHTMLPathAndTokenName objectForKey:htmlFilePath];

    if (nodeList == nil)
    {
        return nil;
    }

    NSEnumerator *nodeEnum = [nodeList objectEnumerator];
    AKDatabaseNode *node;
    while ((node = [nodeEnum nextObject]))
    {
        if ([[node nodeName] isEqualToString:tokenName])
        {
            return node;
        }
    }

    // If we got this far, we couldn't find the node.
    return nil;
}

- (NSString *)frameworkForHTMLFile:(NSString *)htmlFilePath
{
    return [_frameworkNamesByHTMLPath objectForKey:htmlFilePath];
}

@end


@implementation AKDatabase (Private)

// Adds a framework if we haven't seen it before.  We call this each time
// we actually add a bit of API to the database, so that only frameworks
// that we find tokens in are in our list of framework names.
- (void)_seeIfFrameworkIsNew:(NSString *)fwName
{
    if (![_frameworkNames containsObject:fwName])
    {
        [_frameworkNames addObject:fwName];
    }
}

- (NSArray *)_allProtocolsForFramework:(NSString *)fwName
{
    return [_protocolListsByFramework objectForKey:fwName];
}

@end


