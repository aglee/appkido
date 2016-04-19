/*
 * AKDatabase.m
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDatabase.h"

#import "DIGSLog.h"

#import "AKFrameworkConstants.h"
#import "AKDevToolsUtils.h"
#import "AKPrefUtils.h"

#import "AKClassNode.h"
#import "AKProtocolNode.h"
#import "AKGroupNode.h"

#import "AKMacDevTools.h"
#import "AKIPhoneDevTools.h"

@implementation AKDatabase

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithDocSetIndex:(DocSetIndex *)docSetIndex
{
    if ((self = [super init]))
    {
        _docSetIndex = docSetIndex;

        _frameworkNames = [_docSetIndex frameworkNames];

        _classNodesByName = [[NSMutableDictionary alloc] init];

        _protocolNodesByName = [[NSMutableDictionary alloc] init];

        _functionsGroupListsByFramework = [[NSMutableDictionary alloc] init];
        _functionsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

        _globalsGroupListsByFramework = [[NSMutableDictionary alloc] init];
        _globalsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

        _classNodesByHTMLPath = [[NSMutableDictionary alloc] init];
        _protocolNodesByHTMLPath = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}


#pragma mark -
#pragma mark Populating the database

- (void)loadTokens
{

}

#pragma mark -
#pragma mark Getters and setters -- frameworks

- (NSArray *)sortedFrameworkNames
{
    return [self.frameworkNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (BOOL)hasFrameworkWithName:(NSString *)frameworkName
{
    return [self.frameworkNames containsObject:frameworkName];
}

#pragma mark -
#pragma mark Getters and setters -- classes

- (NSArray *)classesForFrameworkNamed:(NSString *)frameworkName
{
    NSMutableArray *classNodes = [NSMutableArray array];

    for (AKClassNode *classNode in [self allClasses])
    {
        if ([classNode.nameOfOwningFramework isEqualToString:frameworkName])
        {
            [classNodes addObject:classNode];
        }
    }

    return classNodes;
}

- (NSArray *)rootClasses
{
    NSMutableArray *result = [NSMutableArray array];

    for (AKClassNode *classNode in [self allClasses])
    {
        if (classNode.parentClass == nil)
        {
            [result addObject:classNode];
        }
    }

    return result;
}

- (NSArray *)allClasses
{
    return _classNodesByName.allValues;
}

- (AKClassNode *)classWithName:(NSString *)className
{
    return _classNodesByName[className];
}

- (void)addClassNode:(AKClassNode *)classNode
{
    // Do nothing if we already have a class with the same name.
    NSString *className = classNode.nodeName;
    if (_classNodesByName[className])
    {
        DIGSLogDebug3(@"Trying to add class [%@] again", className);
        return;
    }

    // Add the class to our lookup by class name.
    _classNodesByName[className] = classNode;
}

#pragma mark -
#pragma mark Getters and setters -- protocols

- (NSArray *)formalProtocolsForFrameworkNamed:(NSString *)frameworkName
{
    return [self _allProtocolsForFrameworkNamed:frameworkName withInformalFlag:NO];
}

- (NSArray *)informalProtocolsForFrameworkNamed:(NSString *)frameworkName
{
    return [self _allProtocolsForFrameworkNamed:frameworkName withInformalFlag:YES];
}

- (NSArray *)allProtocols
{
    return _protocolNodesByName.allValues;
}

- (AKProtocolNode *)protocolWithName:(NSString *)name
{
    return _protocolNodesByName[name];
}

- (void)addProtocolNode:(AKProtocolNode *)protocolNode
{
    // Do nothing if we already have a protocol with the same name.
    NSString *protocolName = protocolNode.nodeName;
    if (_protocolNodesByName[protocolName])
    {
        DIGSLogDebug(@"Trying to add protocol [%@] again", protocolName);
        return;
    }

    // Add the protocol to our lookup by protocol name.
    _protocolNodesByName[protocolName] = protocolNode;
}

#pragma mark -
#pragma mark Getters and setters -- functions

- (NSArray *)functionsGroupsForFrameworkNamed:(NSString *)frameworkName
{
    return _functionsGroupListsByFramework[frameworkName];
}

- (AKGroupNode *)functionsGroupNamed:(NSString *)groupName inFrameworkNamed:(NSString *)frameworkName
{
    return _functionsGroupsByFrameworkAndGroup[frameworkName][groupName];
}

- (void)addFunctionsGroup:(AKGroupNode *)groupNode
{
    NSString *frameworkName = groupNode.nameOfOwningFramework;

    // See if we have any functions groups in the framework yet.
    NSMutableArray *groupList = nil;
    NSMutableDictionary *groupsByName = _functionsGroupsByFrameworkAndGroup[frameworkName];

    if (groupsByName)
    {
        groupList = _functionsGroupListsByFramework[frameworkName];
    }
    else
    {
        groupsByName = [NSMutableDictionary dictionary];
        _functionsGroupsByFrameworkAndGroup[frameworkName] = groupsByName;

        groupList = [NSMutableArray array];
        _functionsGroupListsByFramework[frameworkName] = groupList;
    }

    // Add the functions group if it isn't already in the framework.
    NSString *groupName = groupNode.nodeName;

    if (groupsByName[groupName])
    {
        DIGSLogWarning(@"Trying to add functions group [%@] again", groupName);
    }
    else
    {
        [groupList addObject:groupNode];
        groupsByName[groupNode.nodeName] = groupNode;
    }
}

#pragma mark -
#pragma mark Getters and setters -- globals

- (NSArray *)globalsGroupsForFrameworkNamed:(NSString *)frameworkName
{
    return _globalsGroupListsByFramework[frameworkName];
}

- (AKGroupNode *)globalsGroupNamed:(NSString *)groupName
                  inFrameworkNamed:(NSString *)frameworkName
{
    return _globalsGroupsByFrameworkAndGroup[frameworkName][groupName];
}

- (void)addGlobalsGroup:(AKGroupNode *)groupNode
{
    NSString *frameworkName = groupNode.nameOfOwningFramework;

    // See if we have any globals groups in the framework yet.
    NSMutableArray *groupList = nil;
    NSMutableDictionary *groupsByName = _globalsGroupsByFrameworkAndGroup[frameworkName];

    if (groupsByName)
    {
        groupList = _globalsGroupListsByFramework[frameworkName];
    }
    else
    {
        groupsByName = [NSMutableDictionary dictionary];
        _globalsGroupsByFrameworkAndGroup[frameworkName] = groupsByName;

        groupList = [NSMutableArray array];
        _globalsGroupListsByFramework[frameworkName] = groupList;
    }

    // Add the globals group if it isn't already in the framework.
    NSString *groupName = groupNode.nodeName;

    if (groupsByName[groupName])
    {
        DIGSLogWarning(@"Trying to add globals group [%@] again", groupName);
    }
    else
    {
        [groupList addObject:groupNode];
        groupsByName[groupNode.nodeName] = groupNode;
    }
}

#pragma mark -
#pragma mark Methods that help AKCocoaGlobalsDocParser

- (AKClassNode *)classDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    return _classNodesByHTMLPath[htmlFilePath];
}

- (void)rememberThatClass:(AKClassNode *)classNode
   isDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    _classNodesByHTMLPath[htmlFilePath] = classNode;
}

- (AKProtocolNode *)protocolDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    return _protocolNodesByHTMLPath[htmlFilePath];
}

- (void)rememberThatProtocol:(AKProtocolNode *)protocolNode
      isDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    _protocolNodesByHTMLPath[htmlFilePath] = protocolNode;
}

#pragma mark -
#pragma mark Private methods

- (NSArray *)_allProtocolsForFrameworkNamed:(NSString *)fwName
                           withInformalFlag:(BOOL)informalFlag
{
    NSMutableArray *result = [NSMutableArray array];

    for (AKProtocolNode *protocolNode in [self allProtocols])
    {
        if ((protocolNode.isInformal == informalFlag)
            && [protocolNode.nameOfOwningFramework isEqualToString:fwName])
        {
            [result addObject:protocolNode];
        }
    }

    return result;
}

@end
