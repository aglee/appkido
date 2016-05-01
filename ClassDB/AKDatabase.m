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
#import "AKClassItem.h"
#import "AKProtocolItem.h"
#import "AKGroupItem.h"
#import "AKMacDevTools.h"
#import "AKIPhoneDevTools.h"
#import "DIGSLog.h"
#import "DocSetQuery.h"


@interface AKDatabase ()
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSMutableDictionary *classItemsByName;  // @{CLASS_NAME: AKClassItem}
@end


@implementation AKDatabase

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDocSetIndex:(DocSetIndex *)docSetIndex
{
    if ((self = [super init]))
    {
        _docSetIndex = docSetIndex;
		_frameworkNames = [[NSMutableArray alloc] init];
        _classItemsByName = [[NSMutableDictionary alloc] init];
        _protocolItemsByName = [[NSMutableDictionary alloc] init];
        _functionsGroupListsByFramework = [[NSMutableDictionary alloc] init];
        _functionsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

        _globalsGroupListsByFramework = [[NSMutableDictionary alloc] init];
        _globalsGroupsByFrameworkAndGroup = [[NSMutableDictionary alloc] init];

        _classItemsByHTMLPath = [[NSMutableDictionary alloc] init];
        _protocolItemsByHTMLPath = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithDocSetIndex:nil];
}


#pragma mark - Populating the database

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
        } else if ([tokenType isEqualToString:@"intf"]) {
            [self _addProtocolToken:token];
        } else {

        }
    }
}

- (void)_addClassToken:(DSAToken *)token
{
    NSString *className = token.tokenName;
    NSString *frameworkName = token.metainformation.declaredIn.frameworkName;

    //FIXME: Handle those broken cases where a category is mislabeled as a class ('cl' when it looks to me like it should be 'cat').

    AKClassItem *classItem = [self _getOrAddClassItemWithName:className frameworkName:frameworkName];

    if (classItem) {
        classItem.docSetToken = token;
        [self _setParentOfClassItem:classItem];
        [self _setProtocolItemsOfClassItem:classItem];
    }
}

- (AKClassItem *)_getOrAddClassItemWithName:(NSString *)className frameworkName:(NSString *)frameworkName
{
    if (frameworkName.length == 0) {
        return nil;  //FIXME: This causes a bunch of stuff to be unfindable.
    }

    AKClassItem *classItem = self.classItemsByName[className];

    if (classItem == nil) {
        classItem = [[AKClassItem alloc] initWithTokenName:className database:self frameworkName:frameworkName];
        self.classItemsByName[className] = classItem;
        QLog(@"%@ -- added class %@", self.className, className);
    } else {
        classItem.nameOfOwningFramework = frameworkName;
    }

    return classItem;
}

- (void)_setParentOfClassItem:(AKClassItem *)classItem
{
    if (classItem.docSetToken.superclassContainers.count > 1) {
        QLog(@"%s [ODD] Unexpected multiple inheritance for class %@", __PRETTY_FUNCTION__, classItem.tokenName);
    }

    Container *container = classItem.docSetToken.superclassContainers.anyObject;

    if (container) {
        AKClassItem *parentItem = [self _getOrAddClassItemWithName:container.containerName frameworkName:classItem.nameOfOwningFramework];
        if (classItem.parentClass) {
            QLog(@"%s [ODD] Class item %@ already has parent item %@", __PRETTY_FUNCTION__, classItem.parentClass.tokenName);
        }
        [parentItem addChildClass:classItem];
    } else {
        QLog(@"ROOT CLASS %@", classItem.tokenName);
    }
}

- (void)_addProtocolToken:(DSAToken *)token
{
}

- (void)_setProtocolItemsOfClassItem:(AKClassItem *)classItem
{
    //FIXME: Fill this in.
}

#pragma mark - Getters and setters -- frameworks

- (NSArray *)sortedFrameworkNames
{
    return [self.frameworkNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (BOOL)hasFrameworkWithName:(NSString *)frameworkName
{
    return [self.frameworkNames containsObject:frameworkName];
}

#pragma mark - Getters and setters -- classes

- (NSArray *)classesForFrameworkNamed:(NSString *)frameworkName
{
    NSMutableArray *classItems = [NSMutableArray array];

    for (AKClassItem *classItem in [self allClasses])
    {
        if ([classItem.nameOfOwningFramework isEqualToString:frameworkName])
        {
            [classItems addObject:classItem];
        }
    }

    return classItems;
}

- (NSArray *)rootClasses
{
    NSMutableArray *result = [NSMutableArray array];

    for (AKClassItem *classItem in [self allClasses])
    {
        if (classItem.parentClass == nil)
        {
            [result addObject:classItem];
        }
    }

    return result;
}

- (NSArray *)allClasses
{
    return self.classItemsByName.allValues;
}

- (AKClassItem *)classWithName:(NSString *)className
{
    return self.classItemsByName[className];
}

#pragma mark - Getters and setters -- protocols

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
    NSString *protocolName = protocolItem.tokenName;
    if (_protocolItemsByName[protocolName])
    {
        DIGSLogDebug(@"Trying to add protocol [%@] again", protocolName);
        return;
    }

    // Add the protocol to our lookup by protocol name.
    _protocolItemsByName[protocolName] = protocolItem;
}

#pragma mark - Getters and setters -- functions

- (NSArray *)functionsGroupsForFrameworkNamed:(NSString *)frameworkName
{
    return _functionsGroupListsByFramework[frameworkName];
}

- (AKGroupItem *)functionsGroupNamed:(NSString *)groupName inFrameworkNamed:(NSString *)frameworkName
{
    return _functionsGroupsByFrameworkAndGroup[frameworkName][groupName];
}

- (void)addFunctionsGroup:(AKGroupItem *)groupItem
{
    NSString *frameworkName = groupItem.nameOfOwningFramework;

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
    NSString *groupName = groupItem.tokenName;

    if (groupsByName[groupName])
    {
        DIGSLogWarning(@"Trying to add functions group [%@] again", groupName);
    }
    else
    {
        [groupList addObject:groupItem];
        groupsByName[groupItem.tokenName] = groupItem;
    }
}

#pragma mark - Getters and setters -- globals

- (NSArray *)globalsGroupsForFrameworkNamed:(NSString *)frameworkName
{
    return _globalsGroupListsByFramework[frameworkName];
}

- (AKGroupItem *)globalsGroupNamed:(NSString *)groupName
                  inFrameworkNamed:(NSString *)frameworkName
{
    return _globalsGroupsByFrameworkAndGroup[frameworkName][groupName];
}

- (void)addGlobalsGroup:(AKGroupItem *)groupItem
{
    NSString *frameworkName = groupItem.nameOfOwningFramework;

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
    NSString *groupName = groupItem.tokenName;

    if (groupsByName[groupName])
    {
        DIGSLogWarning(@"Trying to add globals group [%@] again", groupName);
    }
    else
    {
        [groupList addObject:groupItem];
        groupsByName[groupItem.tokenName] = groupItem;
    }
}

#pragma mark - Methods that help AKCocoaGlobalsDocParser

- (AKClassItem *)classDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    return _classItemsByHTMLPath[htmlFilePath];
}

- (void)rememberThatClass:(AKClassItem *)classItem
   isDocumentedInHTMLFile:(NSString *)htmlFilePath
{
    _classItemsByHTMLPath[htmlFilePath] = classItem;
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

#pragma mark - Private methods

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
