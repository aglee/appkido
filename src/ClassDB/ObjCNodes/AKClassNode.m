//
// AKClassNode.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKClassNode.h"

#import "DIGSLog.h"
#import "AKTextUtils.h"
#import "AKDatabase.h"
#import "AKProtocolNode.h"
#import "AKCategoryNode.h"
#import "AKMethodNode.h"
#import "AKNotificationNode.h"
#import "AKCollectionOfNodes.h"

#import "AKAppController.h"  // [agl] doesn't belong in model class, but it's here to support the _addExtraDelegateMethodsTo: kludge.

//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKClassNode (Private)

// Uses plain setter pattern -- doesn't touch anybody's child list.
- (void)_setParentClass:(AKClassNode *)node;

- (void)_addDescendantsToSet:(NSMutableSet *)descendantNodes;
- (void)_addExtraDelegateMethodsTo:(NSMutableArray *)methodsList;
@end


@implementation AKClassNode

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithNodeName:(NSString *)nodeName
    owningFramework:(NSString *)fwName
{
    if ((self = [super initWithNodeName:nodeName owningFramework:fwName]))
    {
        _childClassNodes = [[NSMutableArray alloc] init];
        _categoryNodes = [[NSMutableArray alloc] init];

        _indexOfDelegateMethods = [[AKCollectionOfNodes alloc] init];
        _indexOfNotifications = [[AKCollectionOfNodes alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [_childClassNodes release];
    [_categoryNodes release];

    [_indexOfDelegateMethods release];
    [_indexOfNotifications release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters -- general
//-------------------------------------------------------------------------

- (AKClassNode *)parentClass
{
    return _parentClassNode;
}

- (void)addChildClass:(AKClassNode *)node
{
    // [agl] We check for parent != child to avoid circularity.  This
    // doesn't protect against the general case of a cycle, but it does
    // work around the typo in the Tiger docs where the superclass of
    // NSAnimation was given as NSAnimation.
    if (node == self)
    {
        DIGSLogDebug(
            @"ignoring attempt to make %@ a subclass of itself",
            [self nodeName]);
        return;
    }

    // Handle case where node already has a parent.  This will be a
    // no-op if the node has no parent.
    [[node parentClass] removeChildClass:node];

    // Set new parent-child connections.
    // [agl] Note that this creates an object cycle.
    [node _setParentClass:self];
    [_childClassNodes addObject:node];
}

- (void)removeChildClass:(AKClassNode *)node
{
    int i = [_childClassNodes indexOfObject:node];

    if (i >= 0)
    {
        [node _setParentClass:nil];
        [_childClassNodes removeObjectAtIndex:i];
    }
}

- (NSArray *)childClasses
{
    return _childClassNodes;
}

- (NSSet *)descendantClasses
{
    NSMutableSet *descendantNodes = [NSMutableSet setWithCapacity:50];

    [self _addDescendantsToSet:descendantNodes];

    return descendantNodes;
}

- (BOOL)hasChildClasses
{
    return ([_childClassNodes count] > 0);
}

- (AKCategoryNode *)categoryNamed:(NSString *)catName
{
    NSEnumerator *en = [_categoryNodes objectEnumerator];
    AKDatabaseNode *node;

    while ((node = [en nextObject]))
    {
        if ([[node nodeName] isEqualToString:catName])
        {
            return (AKCategoryNode *)node;
        }
    }

    return nil;
}

- (void)addCategory:(AKCategoryNode *)node
{
    [_categoryNodes addObject:node];
}

- (NSArray *)allCategories
{
    NSMutableArray *result = [NSMutableArray arrayWithArray:_categoryNodes];

    // Get categories from ancestor classes.
    if (_parentClassNode)
    {
        [result addObjectsFromArray:[_parentClassNode allCategories]];
    }

    return result;
}

//-------------------------------------------------------------------------
// Getters and setters -- delegate methods
//-------------------------------------------------------------------------

- (NSArray *)documentedDelegateMethods
{
    NSMutableArray *methodList =
        [NSMutableArray
            arrayWithArray:
                [_indexOfDelegateMethods nodesWithDocumentation]];

    // Handle classes like WebView that have different *kinds* of delegates.
    [self _addExtraDelegateMethodsTo:methodList];

    return methodList;
}

- (AKMethodNode *)delegateMethodWithName:(NSString *)methodName
{
    return (AKMethodNode *)[_indexOfDelegateMethods nodeWithName:methodName];
}

- (void)addDelegateMethod:(AKMethodNode *)methodNode;
{
    [_indexOfDelegateMethods addNode:methodNode];
}

//-------------------------------------------------------------------------
// Getters and setters -- notifications
//-------------------------------------------------------------------------

- (NSArray *)documentedNotifications
{
    return [_indexOfNotifications nodesWithDocumentation];
}

- (AKNotificationNode *)notificationWithName:(NSString *)notificationName
{
    return (AKNotificationNode *)[_indexOfNotifications nodeWithName:notificationName];
}

- (void)addNotification:(AKNotificationNode *)notificationNode;
{
    [_indexOfNotifications addNode:notificationNode];
}

//-------------------------------------------------------------------------
// AKBehaviorNode methods
//-------------------------------------------------------------------------

- (BOOL)isClassNode
{
    return YES;
}

// Overrides inherited method.
- (NSArray *)implementedProtocols
{
    NSMutableArray *result =
        [NSMutableArray arrayWithArray:[super implementedProtocols]];

    // Get protocols from ancestor classes.
    [result addObjectsFromArray:[_parentClassNode implementedProtocols]];

    return result;
}

- (AKMethodNode *)addDeprecatedMethodIfAbsentWithName:(NSString *)methodName
    owningFramework:(NSString *)owningFramework
{
    AKMethodNode *methodNode =
        [super addDeprecatedMethodIfAbsentWithName:methodName owningFramework:owningFramework];

    // If it's neither an instance method nor a class method, but it looks
    // like it might be a delegate method, assume it is one.
    // [agl] FIXME -- This assumption is false for [NSTypesetter lineFragmentRectForProposedRect:remainingRect:].
    if (methodNode == nil)
    {
        if ([methodName ak_contains:@":"])
        {
            methodNode =
                [AKMethodNode
                    nodeWithNodeName:methodName
                    owningFramework:owningFramework];
            [methodNode setIsDeprecated:YES];
            [self addDelegateMethod:methodNode];
        }
        else
        {
            DIGSLogInfo(
                @"Skipping method named %@ because it doesn't look like a delegate method while processing deprecated methods in behavior %@",
                methodName, [self nodeName]);
        }
    }
    
    return methodNode;
}

@end


//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation AKClassNode (Private)

- (void)_setParentClass:(AKClassNode *)node
{
    [node retain];
    [_parentClassNode release];
    _parentClassNode = node;
}

- (void)_addDescendantsToSet:(NSMutableSet *)descendantNodes
{
    NSEnumerator *en = [_childClassNodes objectEnumerator];
    AKClassNode *sub;

    [descendantNodes addObject:self];
    while ((sub = [en nextObject]))
    {
        [sub _addDescendantsToSet:descendantNodes];
    }
}

- (void)_addExtraDelegateMethodsTo:(NSMutableArray *)methodsList
{
    NSEnumerator *methodEnum =
        [[_indexOfInstanceMethods allNodes] objectEnumerator];
    AKMethodNode *methodNode;

    // [agl] KLUDGE Look for method names of the form setFooDelegate:.
    while ((methodNode = [methodEnum nextObject]))
    {
        NSString *methodName = [methodNode nodeName];

        if ([methodName hasPrefix:@"set"]
            && [methodName hasSuffix:@"Delegate:"]
            && ![methodName isEqualToString:@"setDelegate:"])
        {
            NSString *protocolSuffix =
                [[[methodName
                    substringToIndex:([methodName length] - 1)]
                    substringFromIndex:3]
                    uppercaseString];
            NSEnumerator *protocolEnum =
                [[[[NSApp delegate] appDatabase] allProtocols]
                    objectEnumerator];
            AKProtocolNode *protocolNode;

            while ((protocolNode = [protocolEnum nextObject]))
            {
                NSString *protocolName =
                    [[protocolNode nodeName] uppercaseString];

                if ([protocolName hasSuffix:protocolSuffix])
                {
                    NSArray *protocolMethods =
                        [protocolNode documentedInstanceMethods];

                    [methodsList addObjectsFromArray:protocolMethods];
                    break;
                }
            }
        }
    }
}

@end
