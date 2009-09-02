/*
 * AKDatabase.m
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDatabase.h"

#import "DIGSLog.h"

#import "AKFrameworkConstants.h"
#import "AKPrefUtils.h"

#import "AKClassNode.h"
#import "AKProtocolNode.h"
#import "AKGroupNode.h"

#import "AKMacDevTools.h"
#import "AKIPhoneDevTools.h"
#import "AKDocSetIndex.h"
#import "AKOldDatabase.h"
#import "AKDatabaseWithDocSet.h"


@interface AKDatabase (Private)
- (void)_seeIfFrameworkIsNew:(NSString *)fwName;
- (NSArray *)_allProtocolsForFrameworkNamed:(NSString *)fwName;
@end


@implementation AKDatabase

#pragma mark -
#pragma mark Factory methods

+ (AKDocSetIndex *)_docSetIndexForDevTools:(AKDevTools *)devTools
{
    NSString *sdkVersion = [AKPrefUtils sdkVersionPref];
    NSString *docSetPath = [devTools docSetPathForVersion:sdkVersion];
    NSString *basePathForHeaders = [devTools headersPathForVersion:sdkVersion];

    DIGSLogDebug(@"_docSetIndexForDevTools: -- docSetPath is [%@]", docSetPath);

    if (docSetPath == nil || basePathForHeaders == nil)
        return nil;

    return
        [[[AKDocSetIndex alloc]
            initWithDocSetPath:docSetPath
            basePathForHeaders:basePathForHeaders] autorelease];
}


+ (id)databaseForMacPlatform
{
    DIGSLogDebug_EnteringMethod();
    
    static AKDatabase *s_macOSDatabase = nil;

    if (s_macOSDatabase == nil)
    {
        NSString *devToolsPath = [AKPrefUtils devToolsPathPref];
        AKDevTools *devTools = [AKMacDevTools devToolsWithPath:devToolsPath];
        AKDocSetIndex *docSetIndex = [self _docSetIndexForDevTools:devTools];

        if (docSetIndex)
            s_macOSDatabase = [[AKDatabaseWithDocSet alloc] initWithDocSetIndex:docSetIndex];
        else
            s_macOSDatabase = [[AKOldDatabase alloc] initWithDevToolsPath:devToolsPath];

        // For a new user of AppKiDo for Mac OS, only load the "essential"
        // frameworks by default and leave it up to them to add more as needed.
        // It would be nice to simply provide everything, but until we cut down
        // the amount of startup time used by parsing, that will take too long.
        if ([AKPrefUtils selectedFrameworkNamesPref] == nil)
            [AKPrefUtils setSelectedFrameworkNamesPref:AKNamesOfEssentialFrameworks];
    }

    DIGSLogDebug_ExitingMethod();
    return s_macOSDatabase;
}

+ (id)databaseForIPhonePlatform
{
    static AKDatabase *s_iPhoneDatabase = nil;

    if (s_iPhoneDatabase == nil)
    {
        NSString *devToolsPath = [AKPrefUtils devToolsPathPref];
        AKDevTools *devTools = [AKIPhoneDevTools devToolsWithPath:devToolsPath];
        AKDocSetIndex *docSetIndex = [self _docSetIndexForDevTools:devTools];

        s_iPhoneDatabase = [[AKDatabaseWithDocSet alloc] initWithDocSetIndex:docSetIndex];

        // Assume anyone using AppKiDo for iPhone is going to want all possible
        // frameworks in the iPhone SDK by default, and will deselect whichever
        // ones they don't want.  The docset is small enough that we can do this.
        if ([AKPrefUtils selectedFrameworkNamesPref] == nil)
            [AKPrefUtils setSelectedFrameworkNamesPref:[docSetIndex selectableFrameworkNames]];
    }

    return s_iPhoneDatabase;
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)init
{
    if ((self = [super init]))
    {
        _frameworksByName = [[NSMutableDictionary alloc] init];
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
        _offsetsOfAnchorStringsInHTMLFiles = [[NSMutableDictionary alloc] initWithCapacity:30000];

        _frameworkNamesByHTMLPath = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [_frameworksByName release];
    [_frameworkNames release];
    [_namesOfAvailableFrameworks release];

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

    [_frameworkNamesByHTMLPath release];

    [super dealloc];
}


#pragma mark -
#pragma mark Populating the database

- (BOOL)frameworkNameIsSelectable:(NSString *)frameworkName
{
    return YES;
}

- (void)loadTokensForFrameworks:(NSArray *)frameworkNames
{
    if (frameworkNames == nil)
    {
        frameworkNames = AKNamesOfEssentialFrameworks;
    }

    NSEnumerator *fwNameEnum = [frameworkNames objectEnumerator];
    NSString *fwName;

    while ((fwName = [fwNameEnum nextObject]))
    {
        if ([self frameworkNameIsSelectable:fwName])
        {
            NSAutoreleasePool *tempPool = [[NSAutoreleasePool alloc] init];

            DIGSLogDebug(@"===================================================");
            DIGSLogDebug(@"Loading tokens for framework %@", fwName);
            DIGSLogDebug(@"===================================================");

            if ([_delegate respondsToSelector:@selector(database:willLoadTokensForFramework:)])
            {
                [_delegate database:self willLoadTokensForFramework:fwName];
            }

            [self loadTokensForFrameworkNamed:fwName];

            [tempPool release];
        }
    }
}

- (void)loadTokensForFrameworkNamed:(NSString *)frameworkName
{
    DIGSLogError_MissingOverride();
}

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;  // note this is NOT retained
}


#pragma mark -
#pragma mark Getters and setters -- frameworks

- (AKFramework *)frameworkWithName:(NSString *)frameworkName
{
    AKFramework *aFramework = [_frameworksByName objectForKey:frameworkName];

    if (aFramework == nil)
    {
        aFramework = [[[AKFramework alloc] init] autorelease];
        [aFramework setFWDatabase:self];
        [aFramework setFrameworkName:frameworkName];

        [_frameworksByName setObject:aFramework forKey:frameworkName];
    }

    return aFramework;
}

- (NSArray *)frameworkNames
{
    return _frameworkNames;
}

- (NSArray *)sortedFrameworkNames
{
    return [_frameworkNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (BOOL)hasFrameworkWithName:(NSString *)frameworkName
{
    return [_frameworkNames containsObject:frameworkName];
}

- (NSArray *)namesOfAvailableFrameworks
{
    return _namesOfAvailableFrameworks;
}


#pragma mark -
#pragma mark Getters and setters -- classes

- (NSArray *)classesForFrameworkNamed:(NSString *)frameworkName
{
    return [_classListsByFramework objectForKey:frameworkName];
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

- (AKClassNode *)classWithName:(NSString *)className
{
    return [_classNodesByName objectForKey:className];
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
    NSString *frameworkName = [[classNode owningFramework] frameworkName];
    NSMutableArray *classNodes = [_classListsByFramework objectForKey:frameworkName];

    if (classNodes == nil)
    {
        classNodes = [NSMutableArray array];
        [_classListsByFramework setObject:classNodes forKey:frameworkName];
    }

    [classNodes addObject:classNode];

    // Add the framework to our framework list if it's not there already.
    [self _seeIfFrameworkIsNew:frameworkName];
}


#pragma mark -
#pragma mark Getters and setters -- protocols

- (NSArray *)formalProtocolsForFrameworkNamed:(NSString *)frameworkName
{
    NSMutableArray *result = [NSMutableArray array];
    NSEnumerator *en = [[self _allProtocolsForFrameworkNamed:frameworkName] objectEnumerator];
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

- (NSArray *)informalProtocolsForFrameworkNamed:(NSString *)frameworkName
{
    NSMutableArray *result = [NSMutableArray array];
    NSEnumerator *en = [[self _allProtocolsForFrameworkNamed:frameworkName] objectEnumerator];
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
    NSString *frameworkName = [[protocolNode owningFramework] frameworkName];
    NSMutableArray *protocolNodes = [_protocolListsByFramework objectForKey:frameworkName];

    if (protocolNodes == nil)
    {
        protocolNodes = [NSMutableArray array];
        [_protocolListsByFramework setObject:protocolNodes forKey:frameworkName];
    }

    [protocolNodes addObject:protocolNode];

    // Add the framework to our framework list if it's not there already.
    [self _seeIfFrameworkIsNew:frameworkName];
}


#pragma mark -
#pragma mark Getters and setters -- functions

- (int)numberOfFunctionsGroupsForFrameworkNamed:(NSString *)frameworkName
{
    return [[_functionsGroupListsByFramework objectForKey:frameworkName] count];
}

- (NSArray *)functionsGroupsForFrameworkNamed:(NSString *)frameworkName
{
    return [_functionsGroupListsByFramework objectForKey:frameworkName];
}

- (AKGroupNode *)functionsGroupNamed:(NSString *)groupName inFrameworkNamed:(NSString *)frameworkName
{
    return [[_functionsGroupsByFrameworkAndGroup objectForKey:frameworkName] objectForKey:groupName];
}

- (void)addFunctionsGroup:(AKGroupNode *)groupNode
{
    NSString *frameworkName = [[groupNode owningFramework] frameworkName];

    // See if we have any functions groups in the framework yet.
    NSMutableArray *groupList = nil;
    NSMutableDictionary *groupsByName = [_functionsGroupsByFrameworkAndGroup objectForKey:frameworkName];

    if (groupsByName)
    {
        groupList = [_functionsGroupListsByFramework objectForKey:frameworkName];
    }
    else
    {
        groupsByName = [NSMutableDictionary dictionary];
        [_functionsGroupsByFrameworkAndGroup setObject:groupsByName forKey:frameworkName];

        groupList = [NSMutableArray array];
        [_functionsGroupListsByFramework setObject:groupList forKey:frameworkName];
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
    [self _seeIfFrameworkIsNew:frameworkName];
}

- (AKGroupNode *)functionsGroupContainingFunctionNamed:(NSString *)functionName
    inFrameworkNamed:(NSString *)frameworkName
{
    // Get the functions groups for the given framework.
    NSMutableArray *groupList = [_functionsGroupListsByFramework objectForKey:frameworkName];
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


#pragma mark -
#pragma mark Getters and setters -- globals

- (int)numberOfGlobalsGroupsForFrameworkNamed:(NSString *)frameworkName
{
    return [[_globalsGroupListsByFramework objectForKey:frameworkName] count];
}

- (NSArray *)globalsGroupsForFrameworkNamed:(NSString *)frameworkName
{
    return [_globalsGroupListsByFramework objectForKey:frameworkName];
}

- (AKGroupNode *)globalsGroupNamed:(NSString *)groupName inFrameworkNamed:(NSString *)frameworkName
{
    return [[_globalsGroupsByFrameworkAndGroup objectForKey:frameworkName] objectForKey:groupName];
}

- (void)addGlobalsGroup:(AKGroupNode *)groupNode
{
    NSString *frameworkName = [[groupNode owningFramework] frameworkName];

    // See if we have any globals groups in the framework yet.
    NSMutableArray *groupList = nil;
    NSMutableDictionary *groupsByName = [_globalsGroupsByFrameworkAndGroup objectForKey:frameworkName];

    if (groupsByName)
    {
        groupList = [_globalsGroupListsByFramework objectForKey:frameworkName];
    }
    else
    {
        groupsByName = [NSMutableDictionary dictionary];
        [_globalsGroupsByFrameworkAndGroup setObject:groupsByName forKey:frameworkName];

        groupList = [NSMutableArray array];
        [_globalsGroupListsByFramework setObject:groupList forKey:frameworkName];
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
    [self _seeIfFrameworkIsNew:frameworkName];
}

- (AKGroupNode *)globalsGroupContainingGlobalNamed:(NSString *)nameOfGlobal
    inFrameworkNamed:(NSString *)frameworkName
{
    // Get the globals groups for the given framework.
    NSMutableArray *groupList = [_globalsGroupListsByFramework objectForKey:frameworkName];
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


#pragma mark -
#pragma mark Getters and setters -- hyperlink support

- (NSString *)frameworkForHTMLFile:(NSString *)htmlFilePath
{
    return [_frameworkNamesByHTMLPath objectForKey:htmlFilePath];
}

- (void)rememberFrameworkName:(NSString *)frameworkName forHTMLFile:(NSString *)htmlFilePath
{
    [_frameworkNamesByHTMLPath setObject:frameworkName forKey:htmlFilePath];
}

- (AKClassNode *)classDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    return [_classNodesByHTMLPath objectForKey:htmlFilePath];
}

- (void)rememberThatClass:(AKClassNode *)classNode isDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    [_classNodesByHTMLPath setObject:classNode forKey:htmlFilePath];
}

- (AKProtocolNode *)protocolDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    return [_protocolNodesByHTMLPath objectForKey:htmlFilePath];
}

- (void)rememberThatProtocol:(AKProtocolNode *)protocolNode isDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    [_protocolNodesByHTMLPath setObject:protocolNode forKey:htmlFilePath];
}

- (AKFileSection *)rootSectionForHTMLFile:(NSString *)filePath
{
    return [_rootSectionsByHTMLPath objectForKey:filePath];
}

- (void)rememberRootSection:(AKFileSection *)rootSection forHTMLFile:(NSString *)filePath
{
    [_rootSectionsByHTMLPath setObject:rootSection forKey:filePath];
}

- (int)offsetOfAnchorString:(NSString *)anchorString inHTMLFile:(NSString *)filePath
{
    NSMutableDictionary *offsetsByFilePath = [_offsetsOfAnchorStringsInHTMLFiles objectForKey:anchorString];

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

- (void)rememberOffset:(int)anchorOffset ofAnchorString:(NSString *)anchorString inHTMLFile:(NSString *)filePath
{
    NSMutableDictionary *offsetsByFilePath = [_offsetsOfAnchorStringsInHTMLFiles objectForKey:anchorString];

    if (offsetsByFilePath == nil)
    {
        offsetsByFilePath = [NSMutableDictionary dictionary];

        [_offsetsOfAnchorStringsInHTMLFiles setObject:offsetsByFilePath forKey:anchorString];
    }

    NSNumber *offsetValue = [NSNumber numberWithInt:anchorOffset];

    [offsetsByFilePath setObject:offsetValue forKey:filePath];
}

@end


#pragma mark -
#pragma mark Delegate methods

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

- (NSArray *)_allProtocolsForFrameworkNamed:(NSString *)fwName
{
    return [_protocolListsByFramework objectForKey:fwName];
}

@end


