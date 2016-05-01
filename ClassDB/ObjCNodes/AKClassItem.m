//
// AKClassItem.m
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKClassItem.h"
#import "DIGSLog.h"
#import "AKCategoryItem.h"
#import "AKCollectionOfItems.h"
#import "AKDatabase.h"
#import "AKFileSection.h"
#import "AKMethodItem.h"
#import "AKNotificationItem.h"
#import "AKProtocolItem.h"
#import "NSString+AppKiDo.h"


@interface AKClassItem ()
@property (NS_NONATOMIC_IOSONLY, readwrite, weak) AKClassItem *parentClass;
@end


@implementation AKClassItem

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithTokenName:(NSString *)tokenName database:(AKDatabase *)database frameworkName:(NSString *)frameworkName
{
    if ((self = [super initWithTokenName:tokenName database:database frameworkName:frameworkName]))
    {
        _namesOfAllOwningFrameworks = [[NSMutableArray alloc] init];

        if (frameworkName) {
            [_namesOfAllOwningFrameworks addObject:frameworkName];
        }

        _tokenItemDocumentationByFrameworkName = [[NSMutableDictionary alloc] init];

        _childClassItems = [[NSMutableArray alloc] init];
        _categoryItems = [[NSMutableArray alloc] init];

        _indexOfDelegateMethods = [[AKCollectionOfItems alloc] init];
        _indexOfNotifications = [[AKCollectionOfItems alloc] init];
    }

    return self;
}

- (void)dealloc
{
    _indexOfDelegateMethods = nil;

}

#pragma mark -
#pragma mark Getters and setters -- general

- (void)addChildClass:(AKClassItem *)classItem
{
    // We check for parent != child to avoid circularity.  This
    // doesn't protect against the general case of a cycle, but it does
    // work around the typo in the Tiger docs where the superclass of
    // NSAnimation was given as NSAnimation.
    if (classItem == self)
    {
        DIGSLogDebug(@"ignoring attempt to make %@ a subclass of itself", [self tokenName]);
        return;
    }

    [classItem.parentClass removeChildClass:classItem];
    classItem.parentClass = self;
    [_childClassItems addObject:classItem];
}

- (void)removeChildClass:(AKClassItem *)classItem
{
    NSInteger i = [_childClassItems indexOfObject:classItem];

    if (i >= 0)
    {
        [classItem setParentClass:nil];
        [_childClassItems removeObjectAtIndex:i];
    }
}

- (NSArray *)childClasses
{
    return _childClassItems;
}

- (NSSet *)descendantClasses
{
    NSMutableSet *descendantNodes = [NSMutableSet setWithCapacity:50];

    [self _addDescendantsToSet:descendantNodes];

    return descendantNodes;
}

- (BOOL)hasChildClasses
{
    return (_childClassItems.count > 0);
}

- (AKCategoryItem *)categoryNamed:(NSString *)catName
{
    for (AKTokenItem *item in _categoryItems)
    {
        if ([item.tokenName isEqualToString:catName])
        {
            return (AKCategoryItem *)item;
        }
    }

    return nil;
}

- (void)addCategory:(AKCategoryItem *)categoryItem
{
    [_categoryItems addObject:categoryItem];
}

- (NSArray *)allCategories
{
    NSMutableArray *result = [NSMutableArray arrayWithArray:_categoryItems];

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
    return _tokenItemDocumentationByFrameworkName[frameworkName];
}

- (void)associateDocumentation:(AKFileSection *)fileSection
            withFrameworkNamed:(NSString *)frameworkName
{
    if (frameworkName == nil)
    {
        DIGSLogWarning(@"ODD -- nil framework name passed for %@ -- file %@",
                       [self tokenName], [fileSection filePath]);
        return;
    }

    if (![_namesOfAllOwningFrameworks containsObject:frameworkName])
    {
        [_namesOfAllOwningFrameworks addObject:frameworkName];
    }

    _tokenItemDocumentationByFrameworkName[frameworkName] = fileSection;
}

#pragma mark -
#pragma mark Getters and setters -- delegate methods

- (NSArray *)documentedDelegateMethods
{
    NSMutableArray *methodList = [[_indexOfDelegateMethods tokenItemsWithDocumentation] mutableCopy];

    // Handle classes like WebView that have different *kinds* of delegates.
    [self _addExtraDelegateMethodsTo:methodList];

    return methodList;
}

- (AKMethodItem *)delegateMethodWithName:(NSString *)methodName
{
    return (AKMethodItem *)[_indexOfDelegateMethods itemWithTokenName:methodName];
}

- (void)addDelegateMethod:(AKMethodItem *)methodItem
{
    [_indexOfDelegateMethods addTokenItem:methodItem];
}

#pragma mark -
#pragma mark Getters and setters -- notifications

- (NSArray *)documentedNotifications
{
    return [_indexOfNotifications tokenItemsWithDocumentation];
}

- (AKNotificationItem *)notificationWithName:(NSString *)notificationName
{
    return (AKNotificationItem *)[_indexOfNotifications itemWithTokenName:notificationName];
}

- (void)addNotification:(AKNotificationItem *)notificationItem
{
    [_indexOfNotifications addTokenItem:notificationItem];
}

#pragma mark -
#pragma mark AKBehaviorItem methods

- (BOOL)isClassItem
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

- (AKMethodItem *)addDeprecatedMethodIfAbsentWithName:(NSString *)methodName
                                        frameworkName:(NSString *)frameworkName
{
    AKMethodItem *methodItem = [super addDeprecatedMethodIfAbsentWithName:methodName
                                                            frameworkName:frameworkName];

    // If it's neither an instance method nor a class method, but it looks
    // like it might be a delegate method, assume it is one.
    //TODO: Old note to self says this assumption is false for [NSTypesetter lineFragmentRectForProposedRect:remainingRect:].  Check on this.
    if (methodItem == nil)
    {
        if ([methodName ak_contains:@":"])
        {
            methodItem = [[AKMethodItem alloc] initWithTokenName:methodName
                                                        database:self.owningDatabase
                                                   frameworkName:frameworkName
                                                  owningBehavior:self];
            [methodItem setIsDeprecated:YES];
            [self addDelegateMethod:methodItem];
        }
        else
        {
            DIGSLogInfo(@"Skipping method named %@ because it doesn't look like a delegate method"
                        @" while processing deprecated methods in behavior %@",
                        methodName, [self tokenName]);
        }
    }
    
    return methodItem;
}

#pragma mark -
#pragma mark AKTokenItem methods

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
    
    for (AKClassItem *sub in _childClassItems)
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
    NSString *possibleDelegateProtocolName = [self.tokenName stringByAppendingString:@"Delegate"];
    AKProtocolItem *delegateProtocol = [db protocolWithName:possibleDelegateProtocolName];
    
    if (delegateProtocol)
    {
        [methodsList addObjectsFromArray:[delegateProtocol documentedInstanceMethods]];
    }

    // Look for instance method names of the form setFooDelegate:.
    //TODO: To be really thorough, check for fooDelegate properties.
    for (AKMethodItem *methodItem in [self instanceMethodItems])
    {
        NSString *methodName = methodItem.tokenName;

        if ([methodName hasPrefix:@"set"]
            && [methodName hasSuffix:@"Delegate:"]
            && ![methodName isEqualToString:@"setDelegate:"])
        {
            //TODO: Can't I just look for protocol FooDelegate?
            NSString *protocolSuffix = [[methodName substringToIndex:(methodName.length - 1)]
                                         substringFromIndex:3].uppercaseString;
            
            for (AKProtocolItem *protocolItem in [db allProtocols])
            {
                NSString *protocolName = protocolItem.tokenName.uppercaseString;

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