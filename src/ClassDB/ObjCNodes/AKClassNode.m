//
// AKClassNode.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKClassNode.h"

#import "DIGSLog.h"

#import "AKCategoryNode.h"
#import "AKCollectionOfNodes.h"
#import "AKDatabase.h"
#import "AKMethodNode.h"
#import "AKNotificationNode.h"
#import "AKProtocolNode.h"
#import "AKTextUtils.h"

#import "AKAppController.h"  // [agl] KLUDGE doesn't belong in model class, but it's here to support the _addExtraDelegateMethodsTo: kludge.


@interface AKClassNode ()
@property (nonatomic, weak) AKClassNode *parentClass;
@end


@implementation AKClassNode
{



    NSMutableArray *_namesOfAllOwningFrameworks;

    // Keys are names of owning frameworks. Values are the root file sections
    // containing documentation for the framework.
    NSMutableDictionary *_nodeDocumentationByFrameworkName;




    // Contains AKClassNodes, one for each child class.
    NSMutableArray *_childClassNodes;

    // Contains AKCategoryNodes, one for each category that extends this class.
    NSMutableArray *_categoryNodes;

    // Contains AKMethodNodes, one for each delegate method that has been
    // found in the documentation for this class.
    AKCollectionOfNodes *_indexOfDelegateMethods;

    // Contains AKNotificationNodes, one for each notification that has been
    // found in the documentation for this class.
    AKCollectionOfNodes *_indexOfNotifications;
}

@synthesize parentClass = _parentClassNode;

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithNodeName:(NSString *)nodeName owningFramework:(AKFramework *)owningFramework
{
    if ((self = [super initWithNodeName:nodeName owningFramework:owningFramework]))
    {
        _namesOfAllOwningFrameworks = [[NSMutableArray alloc] init];
        [_namesOfAllOwningFrameworks addObject:[owningFramework frameworkName]];

        _nodeDocumentationByFrameworkName = [[NSMutableDictionary alloc] init];

        _childClassNodes = [[NSMutableArray alloc] init];
        _categoryNodes = [[NSMutableArray alloc] init];

        _indexOfDelegateMethods = [[AKCollectionOfNodes alloc] init];
        _indexOfNotifications = [[AKCollectionOfNodes alloc] init];
    }

    return self;
}


#pragma mark -
#pragma mark Getters and setters -- general

- (void)addChildClass:(AKClassNode *)node
{
    // [agl] We check for parent != child to avoid circularity.  This
    // doesn't protect against the general case of a cycle, but it does
    // work around the typo in the Tiger docs where the superclass of
    // NSAnimation was given as NSAnimation.
    if (node == self)
    {
        DIGSLogDebug(@"ignoring attempt to make %@ a subclass of itself", [self nodeName]);
        return;
    }

    // Handle case where node already has a parent.  This will be a
    // no-op if the node has no parent.
    [[node parentClass] removeChildClass:node];

    // Set new parent-child connections.
    // [agl] Note that this creates an object cycle.
    [node setParentClass:self];
    [_childClassNodes addObject:node];
}

- (void)removeChildClass:(AKClassNode *)node
{
    NSInteger i = [_childClassNodes indexOfObject:node];

    if (i >= 0)
    {
        [node setParentClass:nil];
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
    for (AKDatabaseNode *node in _categoryNodes)
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


#pragma mark -
#pragma mark Getters and setters -- multiple owning frameworks

- (NSArray *)namesOfAllOwningFrameworks
{
    return _namesOfAllOwningFrameworks;
}

- (AKFileSection *)documentationAssociatedWithFrameworkNamed:(NSString *)frameworkName
{
    return [_nodeDocumentationByFrameworkName objectForKey:frameworkName];
}

- (void)associateDocumentation:(AKFileSection *)fileSection
            withFrameworkNamed:(NSString *)frameworkName
{
    if (frameworkName == nil)
    {
        DIGSLogWarning(@"ODD -- nil framework name passed for %@ -- file %@",
                       [self nodeName], [fileSection filePath]);
        return;
    }

    if (![_namesOfAllOwningFrameworks containsObject:frameworkName])
    {
        [_namesOfAllOwningFrameworks addObject:frameworkName];
    }

    [_nodeDocumentationByFrameworkName setObject:fileSection forKey:frameworkName];
}


#pragma mark -
#pragma mark Getters and setters -- delegate methods

- (NSArray *)documentedDelegateMethods
{
    NSMutableArray *methodList = [[_indexOfDelegateMethods nodesWithDocumentation] mutableCopy];

    // Handle classes like WebView that have different *kinds* of delegates.
    [self _addExtraDelegateMethodsTo:methodList];

    return methodList;
}

- (AKMethodNode *)delegateMethodWithName:(NSString *)methodName
{
    return (AKMethodNode *)[_indexOfDelegateMethods nodeWithName:methodName];
}

- (void)addDelegateMethod:(AKMethodNode *)methodNode
{
    [_indexOfDelegateMethods addNode:methodNode];
}


#pragma mark -
#pragma mark Getters and setters -- notifications

- (NSArray *)documentedNotifications
{
    return [_indexOfNotifications nodesWithDocumentation];
}

- (AKNotificationNode *)notificationWithName:(NSString *)notificationName
{
    return (AKNotificationNode *)[_indexOfNotifications nodeWithName:notificationName];
}

- (void)addNotification:(AKNotificationNode *)notificationNode
{
    [_indexOfNotifications addNode:notificationNode];
}


#pragma mark -
#pragma mark AKBehaviorNode methods

- (BOOL)isClassNode
{
    return YES;
}

- (NSArray *)implementedProtocols
{
    NSMutableArray *result = [NSMutableArray arrayWithArray:[super implementedProtocols]];

    // Get protocols from ancestor classes.
    [result addObjectsFromArray:[_parentClassNode implementedProtocols]];

    return result;
}

- (AKMethodNode *)addDeprecatedMethodIfAbsentWithName:(NSString *)methodName
                                      owningFramework:(AKFramework *)owningFramework
{
    AKMethodNode *methodNode = [super addDeprecatedMethodIfAbsentWithName:methodName
                                                          owningFramework:owningFramework];

    // If it's neither an instance method nor a class method, but it looks
    // like it might be a delegate method, assume it is one.
    // [agl] FIXME -- This assumption is false for [NSTypesetter lineFragmentRectForProposedRect:remainingRect:].
    if (methodNode == nil)
    {
        if ([methodName ak_contains:@":"])
        {
            methodNode = [[AKMethodNode alloc] initWithNodeName:methodName
                                                owningFramework:owningFramework
                                                 owningBehavior:self];
            [methodNode setIsDeprecated:YES];
            [self addDelegateMethod:methodNode];
        }
        else
        {
            DIGSLogInfo(@"Skipping method named %@ because it doesn't look like a delegate method"
                        @" while processing deprecated methods in behavior %@",
                        methodName, [self nodeName]);
        }
    }
    
    return methodNode;
}


#pragma mark -
#pragma mark AKDatabaseNode methods

- (void)setOwningFramework:(AKFramework *)aFramework
{
    [super setOwningFramework:aFramework];

    // Move this framework name to the beginning of _namesOfAllOwningFrameworks.
    NSString *frameworkName = [aFramework frameworkName];
    if (frameworkName)
    {
        [_namesOfAllOwningFrameworks removeObject:frameworkName];
        [_namesOfAllOwningFrameworks insertObject:frameworkName atIndex:0];
    }
}

#pragma mark -
#pragma mark Private methods

- (void)_addDescendantsToSet:(NSMutableSet *)descendantNodes
{
    [descendantNodes addObject:self];
    
    for (AKClassNode *sub in _childClassNodes)
    {
        [sub _addDescendantsToSet:descendantNodes];
    }
}

// [agl] KLUDGE Look for method names of the form setFooDelegate:.
// [agl] KLUDGE Look for a protocol named ThisClassDelegate.
- (void)_addExtraDelegateMethodsTo:(NSMutableArray *)methodsList
{
    // Look for a protocol named ThisClassDelegate.
    AKDatabase *db = [[NSApp delegate] appDatabase];
    NSString *possibleDelegateProtocolName = [[self nodeName] stringByAppendingString:@"Delegate"];
    AKProtocolNode *delegateProtocol = [db protocolWithName:possibleDelegateProtocolName];
    
    if (delegateProtocol)
    {
        [methodsList addObjectsFromArray:[delegateProtocol documentedInstanceMethods]];
    }

    // Look for instance method names of the form setFooDelegate:.
    for (AKMethodNode *methodNode in [self instanceMethodNodes])
    {
        NSString *methodName = [methodNode nodeName];

        if ([methodName hasPrefix:@"set"]
            && [methodName hasSuffix:@"Delegate:"]
            && ![methodName isEqualToString:@"setDelegate:"])
        {
            // [agl] FIXME Can't I just look for protocol FooDelegate?
            NSString *protocolSuffix = [[[methodName substringToIndex:([methodName length] - 1)]
                                         substringFromIndex:3]
                                        uppercaseString];
            
            for (AKProtocolNode *protocolNode in [db allProtocols])
            {
                NSString *protocolName = [[protocolNode nodeName] uppercaseString];

                if ([protocolName hasSuffix:protocolSuffix])
                {
                    [methodsList addObjectsFromArray:[protocolNode documentedInstanceMethods]];
                    
                    break;
                }
            }
        }
    }
}

@end
