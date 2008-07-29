/*
 * AKDatabase.m
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDatabase.h"

#import "DIGSLog.h"

#import "AKFrameworkConstants.h"
#import "AKPrefConstants.h"
#import "AKPrefUtils.h"
#import "AKSortUtils.h"

#import "AKFileSection.h"
#import "AKFramework.h"
#import "AKClassNode.h"
#import "AKProtocolNode.h"
#import "AKFunctionNode.h"
#import "AKGlobalsNode.h"
#import "AKGroupNode.h"


@interface AKDatabase (Private)
- (void)_seeIfFrameworkIsNew:(NSString *)fwName;
- (NSArray *)_allProtocolsForFramework:(NSString *)fwName;
@end


@implementation AKDatabase

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (AKDatabase *)defaultDatabase
{
    static AKDatabase *s_defaultDatabase = nil;

    if (!s_defaultDatabase)
    {
        s_defaultDatabase = [[self alloc] init];
    }

    return s_defaultDatabase;
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)init
{
    if ((self = [super init]))
    {
        _frameworkNames = [[NSMutableArray alloc] init];

        _classNodesByName = [[NSMutableDictionary alloc] init];
        _classListsByFramework = [[NSMutableDictionary alloc] init];

        _protocolNodesByName = [[NSMutableDictionary alloc] init];
        _protocolListsByFramework = [[NSMutableDictionary alloc] init];

        _functionsGroupListsByFramework = [[NSMutableDictionary alloc] init];
        _functionsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

        _globalsGroupListsByFramework = [[NSMutableDictionary alloc] init];
        _globalsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

        _frameworkNamesByHTMLFilePath =
            [[NSMutableDictionary alloc] init];
        _classNodesByHTMLFilePath =
            [[NSMutableDictionary alloc] init];
        _protocolNodesByHTMLFilePath =
            [[NSMutableDictionary alloc] init];

        _rootSectionsByHTMLFilePath = [[NSMutableDictionary alloc] init];

        _offsetsOfAnchorStringsInHTMLFiles =
            [[NSMutableDictionary alloc] initWithCapacity:30000];
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

    [_frameworkNamesByHTMLFilePath release];
    [_classNodesByHTMLFilePath release];
    [_protocolNodesByHTMLFilePath release];

    [_rootSectionsByHTMLFilePath release];

    [_offsetsOfAnchorStringsInHTMLFiles release];

    [super dealloc];
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
}

/*
- (void)addFunctionNode:(AKFunctionNode *)functionNode
{
    NSString *fwName = [functionNode owningFramework];

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

    // See if the specified functions group is in the framework yet.
    NSString *groupName = [functionNode groupName];
    AKGroupNode *groupNode = [groupsByName objectForKey:groupName];

    if (!groupNode)
    {
        groupNode =
            [[AKGroupNode alloc]
                initWithNodeName:groupName
                owningFramework:fwName];
        [groupList addObject:groupNode];
        [groupsByName setObject:groupNode forKey:[groupNode nodeName]];
    }

    // Add the function to the group.
    [groupNode addSubnode:functionNode];
}
*/

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
}



//-------------------------------------------------------------------------
// Getters and setters -- hyperlink support
//-------------------------------------------------------------------------

- (NSString *)frameworkForHTMLFile:(NSString *)htmlFilePath
{
    return [_frameworkNamesByHTMLFilePath objectForKey:htmlFilePath];
}

- (void)rememberFramework:(NSString *)frameworkName
    forHTMLFile:(NSString *)htmlFilePath
{
    [_frameworkNamesByHTMLFilePath setObject:frameworkName forKey:htmlFilePath];
}

- (AKClassNode *)classDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    return [_classNodesByHTMLFilePath objectForKey:htmlFilePath];
}

- (void)rememberThatClass:(AKClassNode *)classNode
    isDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    [_classNodesByHTMLFilePath setObject:classNode forKey:htmlFilePath];
}

- (AKProtocolNode *)protocolDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    return [_protocolNodesByHTMLFilePath objectForKey:htmlFilePath];
}

- (void)rememberThatProtocol:(AKProtocolNode *)protocolNode
    isDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    [_protocolNodesByHTMLFilePath setObject:protocolNode forKey:htmlFilePath];
}

- (AKFileSection *)rootSectionForHTMLFile:(NSString *)filePath
{
    return [_rootSectionsByHTMLFilePath objectForKey:filePath];
}

- (void)rememberRootSection:(AKFileSection *)rootSection
    forHTMLFile:(NSString *)filePath
{
    [_rootSectionsByHTMLFilePath setObject:rootSection forKey:filePath];
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

@end


@implementation AKDatabase (Private)

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

