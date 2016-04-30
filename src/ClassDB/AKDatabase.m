/*
 * AKDatabase.m
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDatabase.h"
#import "AKFrameworkConstants.h"
#import "AKDevToolsUtils.h"
#import "AKPrefUtils.h"
#import "AKClassNode.h"
#import "AKProtocolItem.h"
#import "AKGroupNode.h"
#import "AKMacDevTools.h"
#import "AKIPhoneDevTools.h"
#import "DIGSLog.h"
#import "DocSetQuery.h"


@interface AKDatabase ()
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSMutableDictionary *classNodesByName;  // @{CLASS_NAME: AKClassNode}
@end


@implementation AKDatabase

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithDocSetIndex:(DocSetIndex *)docSetIndex
{
    if ((self = [super init]))
    {
        _docSetIndex = docSetIndex;
		_frameworkNames = [[NSMutableArray alloc] init];
        _classNodesByName = [[NSMutableDictionary alloc] init];
        _protocolItemsByName = [[NSMutableDictionary alloc] init];
        _functionsGroupListsByFramework = [[NSMutableDictionary alloc] init];
        _functionsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

        _globalsGroupListsByFramework = [[NSMutableDictionary alloc] init];
        _globalsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

        _classNodesByHTMLPath = [[NSMutableDictionary alloc] init];
        _protocolItemsByHTMLPath = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithDocSetIndex:nil];
}


#pragma mark -
#pragma mark Populating the database

- (NSArray *)_arrayWithAllFrameworkNames
{
	NSError *error;
	DocSetQuery *query = [self.docSetIndex queryWithEntityName:@"Header"];
	query.distinctKeyPathsString = @"frameworkName";
	query.predicateString = @"frameworkName != NULL";
	NSArray *fetchedObjects = [query fetchObjectsWithError:&error];
	fetchedObjects = [fetchedObjects valueForKey:@"frameworkName"];
	fetchedObjects = [fetchedObjects sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	return fetchedObjects;
}

- (NSArray *)_arrayWithAllTokens
{
	NSError *error;
    DocSetQuery *query = [self.docSetIndex queryWithEntityName:@"Token"];
	query.predicateString = @"language.fullName = 'Objective-C'";
    return [query fetchObjectsWithError:&error];
}

- (void)populate
{
	_frameworkNames = [self _arrayWithAllFrameworkNames];

    NSArray *allTokens = [self _arrayWithAllTokens];
    for (DSAToken *token in allTokens) {
        NSString *tokenType = token.tokenType.typeName;

        if ([tokenType isEqualToString:@"cl"]) {
            [self _addClassToken:token];
        } else if ([tokenType isEqualToString:@"cl"]) {
            [self _addClassToken:token];
        } else {

        }
    }
}

- (void)_addClassToken:(DSAToken *)token
{
    NSString *className = token.tokenName;
    NSString *frameworkName = token.metainformation.declaredIn.frameworkName;

    //FIXME: Handle those broken cases where a category is mislabeled as a class ('cl' when it looks to me like it should be 'cat').

    AKClassNode *classNode = [self _getOrAddClassNodeWithName:className frameworkName:frameworkName];

    if (classNode) {
        classNode.docSetToken = token;
        [self _setParentNodeOfClassNode:classNode];
        [self _setProtocolItemsOfClassNode:classNode];
    }
}

- (void)_addProtocolToken:(DSAToken *)token
{
}

- (AKClassNode *)_getOrAddClassNodeWithName:(NSString *)className frameworkName:(NSString *)frameworkName
{
    if (frameworkName.length == 0) {
        return nil;  //FIXME: This causes a bunch of stuff to be unfindable.
    }

    AKClassNode *classNode = self.classNodesByName[className];

    if (classNode == nil) {
        classNode = [[AKClassNode alloc] initWithNodeName:className database:self frameworkName:frameworkName];
        self.classNodesByName[className] = classNode;
        QLog(@"%@ -- added class %@", self.className, className);
    } else {
        classNode.nameOfOwningFramework = frameworkName;
    }

    return classNode;
}

- (void)_setParentNodeOfClassNode:(AKClassNode *)classNode
{
    if (classNode.docSetToken.superclassContainers.count > 1) {
        QLog(@"%s [ODD] Unexpected multiple inheritance for class %@", __PRETTY_FUNCTION__, classNode.nodeName);
    }

    Container *container = classNode.docSetToken.superclassContainers.anyObject;

    if (container) {
        AKClassNode *parentNode = [self _getOrAddClassNodeWithName:container.containerName frameworkName:classNode.nameOfOwningFramework];
        if (classNode.parentClass) {
            QLog(@"%s [ODD] Class node %@ already has parent node %@", __PRETTY_FUNCTION__, classNode.parentClass.nodeName);
        }
        [parentNode addChildClass:classNode];
    } else {
        QLog(@"ROOT CLASS %@", classNode.nodeName);
    }
}

- (void)_setProtocolItemsOfClassNode:(AKClassNode *)classNode
{
    //FIXME: Fill this in.
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
    return self.classNodesByName.allValues;
}

- (AKClassNode *)classWithName:(NSString *)className
{
    return self.classNodesByName[className];
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
    return _protocolItemsByName.allValues;
}

- (AKProtocolItem *)protocolWithName:(NSString *)name
{
    return _protocolItemsByName[name];
}

- (void)addProtocolItem:(AKProtocolItem *)protocolItem
{
    // Do nothing if we already have a protocol with the same name.
    NSString *protocolName = protocolItem.nodeName;
    if (_protocolItemsByName[protocolName])
    {
        DIGSLogDebug(@"Trying to add protocol [%@] again", protocolName);
        return;
    }

    // Add the protocol to our lookup by protocol name.
    _protocolItemsByName[protocolName] = protocolItem;
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

- (AKProtocolItem *)protocolDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    return _protocolItemsByHTMLPath[htmlFilePath];
}

- (void)rememberThatProtocol:(AKProtocolItem *)protocolItem
      isDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    _protocolItemsByHTMLPath[htmlFilePath] = protocolItem;
}

#pragma mark -
#pragma mark Private methods

- (NSArray *)_allProtocolsForFrameworkNamed:(NSString *)fwName
                           withInformalFlag:(BOOL)informalFlag
{
    NSMutableArray *result = [NSMutableArray array];

    for (AKProtocolItem *protocolItem in [self allProtocols])
    {
        if ((protocolItem.isInformal == informalFlag)
            && [protocolItem.nameOfOwningFramework isEqualToString:fwName])
        {
            [result addObject:protocolItem];
        }
    }

    return result;
}

@end
