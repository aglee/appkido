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
#import "AKFileSection.h"
#import "AKMethodNode.h"
#import "AKNotificationNode.h"
#import "AKProtocolItem.h"
#import "NSString+AppKiDo.h"


@interface AKClassNode ()
@property (NS_NONATOMIC_IOSONLY, readwrite, weak) AKClassNode *parentClass;
@end


@implementation AKClassNode

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithNodeName:(NSString *)nodeName database:(AKDatabase *)database frameworkName:(NSString *)frameworkName
{
    if ((self = [super initWithNodeName:nodeName database:database frameworkName:frameworkName]))
    {
        _namesOfAllOwningFrameworks = [[NSMutableArray alloc] init];

        if (frameworkName) {
            [_namesOfAllOwningFrameworks addObject:frameworkName];
        }

        _nodeDocumentationByFrameworkName = [[NSMutableDictionary alloc] init];

        _childClassNodes = [[NSMutableArray alloc] init];
        _categoryNodes = [[NSMutableArray alloc] init];

        _indexOfDelegateMethods = [[AKCollectionOfNodes alloc] init];
        _indexOfNotifications = [[AKCollectionOfNodes alloc] init];
    }

    return self;
}

- (void)dealloc
{
    _indexOfDelegateMethods = nil;

}

#pragma mark -
#pragma mark Getters and setters -- general

- (void)addChildClass:(AKClassNode *)node
{
    // We check for parent != child to avoid circularity.  This
    // doesn't protect against the general case of a cycle, but it does
    // work around the typo in the Tiger docs where the superclass of
    // NSAnimation was given as NSAnimation.
    if (node == self)
    {
        DIGSLogDebug(@"ignoring attempt to make %@ a subclass of itself", [self nodeName]);
        return;
    }

    [node.parentClass removeChildClass:node];
    node.parentClass = self;
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
    return (_childClassNodes.count > 0);
}

- (AKCategoryNode *)categoryNamed:(NSString *)catName
{
    for (AKDocSetTokenItem *node in _categoryNodes)
    {
        if ([node.nodeName isEqualToString:catName])
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
    if (_parentClass)
    {
        [result addObjectsFromArray:[_parentClass allCategories]];
    }

    return result;
}

#pragma mark -
#pragma mark Getters and setters -- multiple owning frameworks

- (NSArray *)namesOfAllOwningFrameworks
{
    return _namesOfAllOwningFrameworks;
}

- (BOOL)isOwnedByFrameworkNamed:(NSString *)frameworkName
{
    return [_namesOfAllOwningFrameworks containsObject:frameworkName];
}

- (AKFileSection *)documentationAssociatedWithFrameworkNamed:(NSString *)frameworkName
{
    return _nodeDocumentationByFrameworkName[frameworkName];
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

    _nodeDocumentationByFrameworkName[frameworkName] = fileSection;
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
#pragma mark AKBehaviorItem methods

- (BOOL)isClassNode
{
    return YES;
}

- (NSArray *)implementedProtocols
{
    NSMutableArray *result = [NSMutableArray arrayWithArray:[super implementedProtocols]];

    // Get protocols from ancestor classes.
    [result addObjectsFromArray:[_parentClass implementedProtocols]];

    return result;
}

- (AKMethodNode *)addDeprecatedMethodIfAbsentWithName:(NSString *)methodName
                                        frameworkName:(NSString *)frameworkName
{
    AKMethodNode *methodNode = [super addDeprecatedMethodIfAbsentWithName:methodName
                                                            frameworkName:frameworkName];

    // If it's neither an instance method nor a class method, but it looks
    // like it might be a delegate method, assume it is one.
    //TODO: Old note to self says this assumption is false for [NSTypesetter lineFragmentRectForProposedRect:remainingRect:].  Check on this.
    if (methodNode == nil)
    {
        if ([methodName ak_contains:@":"])
        {
            methodNode = [[AKMethodNode alloc] initWithNodeName:methodName
                                                        database:self.owningDatabase
                                                   frameworkName:frameworkName
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
#pragma mark AKDocSetTokenItem methods

- (void)setNameOfOwningFramework:(NSString *)frameworkName
{
    super.nameOfOwningFramework = frameworkName;

    // Move this framework name to the beginning of _namesOfAllOwningFrameworks.
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

// Look for a protocol named ThisClassDelegate.
// Look for instance method names of the form setFooDelegate:.
- (void)_addExtraDelegateMethodsTo:(NSMutableArray *)methodsList
{
    // Look for a protocol named ThisClassDelegate.
    AKDatabase *db = self.owningDatabase;
    NSString *possibleDelegateProtocolName = [self.nodeName stringByAppendingString:@"Delegate"];
    AKProtocolItem *delegateProtocol = [db protocolWithName:possibleDelegateProtocolName];
    
    if (delegateProtocol)
    {
        [methodsList addObjectsFromArray:[delegateProtocol documentedInstanceMethods]];
    }

    // Look for instance method names of the form setFooDelegate:.
    //TODO: To be really thorough, check for fooDelegate properties.
    for (AKMethodNode *methodNode in [self instanceMethodNodes])
    {
        NSString *methodName = methodNode.nodeName;

        if ([methodName hasPrefix:@"set"]
            && [methodName hasSuffix:@"Delegate:"]
            && ![methodName isEqualToString:@"setDelegate:"])
        {
            //TODO: Can't I just look for protocol FooDelegate?
            NSString *protocolSuffix = [[methodName substringToIndex:(methodName.length - 1)]
                                         substringFromIndex:3].uppercaseString;
            
            for (AKProtocolItem *protocolItem in [db allProtocols])
            {
                NSString *protocolName = protocolItem.nodeName.uppercaseString;

                if ([protocolName hasSuffix:protocolSuffix])
                {
                    [methodsList addObjectsFromArray:[protocolItem documentedInstanceMethods]];
                    
                    break;
                }
            }
        }
    }
}

@end
