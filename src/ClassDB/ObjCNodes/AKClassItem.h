//
// AKClassItem.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKBehaviorItem.h"

@class AKPropertyItem;
@class AKNotificationItem;
@class AKCategoryItem;
@class AKCollectionOfItems;

/*!
 * Represents an Objective-C class, which in addition to having methods can have
 * categories, subclasses, and a superclass; can have delegate methods; can
 * respond to notifications; and can span multiple frameworks by way of its
 * categories.
 *
 * We use the terms "parent class" and "child class" rather than "superclass"
 * and "subclass", to avoid confusion.
 */
@interface AKClassItem : AKBehaviorItem
{
@private
    // Elements are strings.
    NSMutableArray *_namesOfAllOwningFrameworks;

    // Keys are names of owning frameworks. Values are the root file sections
    // containing documentation for the framework.
    NSMutableDictionary *_tokenItemDocumentationByFrameworkName;

    // Contains AKClassItems, one for each child class.
    NSMutableArray *_childClassItems;

    // Contains AKCategoryItems, one for each category that extends this class.
    NSMutableArray *_categoryItems;

    // Contains AKMethodItems, one for each delegate method that has been
    // found in the documentation for this class.
    AKCollectionOfItems *_indexOfDelegateMethods;

    // Contains AKNotificationItems, one for each notification that has been
    // found in the documentation for this class.
    AKCollectionOfItems *_indexOfNotifications;
}

@property (NS_NONATOMIC_IOSONLY, readonly, weak) AKClassItem *parentClass;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *childClasses;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSSet *descendantClasses;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasChildClasses;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *allCategories;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *documentedDelegateMethods;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *documentedNotifications;

/*!
 * Names of all frameworks the class belongs to. The first element of the
 * returned array is the name of the framework the class was declared in (its
 * owningFramework). After that, the order of the array is the order in which it
 * was discovered that the class belongs to the framework.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *namesOfAllOwningFrameworks;

#pragma mark -
#pragma mark Getters and setters -- general

- (void)addChildClass:(AKClassItem *)classItem;
- (void)removeChildClass:(AKClassItem *)classItem;

- (void)addCategory:(AKCategoryItem *)categoryItem;
- (AKCategoryItem *)categoryNamed:(NSString *)catName;

#pragma mark -
#pragma mark Getters and setters -- multiple owning frameworks

- (BOOL)isOwnedByFrameworkNamed:(NSString *)frameworkName;

- (AKFileSection *)documentationAssociatedWithFrameworkNamed:(NSString *)frameworkName;

/*!
 * It's possible for a class to belong to multiple frameworks. The usual example
 * I give is NSString, which is declared in Foundation and also has methods in
 * AppKit by way of a category. We keep track of all the frameworks that "own" a
 * class, and all the doc files that are associated with each framework.
 */
- (void)associateDocumentation:(AKFileSection *)fileSection
            withFrameworkNamed:(NSString *)frameworkName;

#pragma mark -
#pragma mark Getters and setters -- delegate methods

- (AKMethodItem *)delegateMethodWithName:(NSString *)methodName;

/*! Does nothing if a delegate method with the same name already exists. */
- (void)addDelegateMethod:(AKMethodItem *)methodItem;

#pragma mark -
#pragma mark Getters and setters -- notifications

- (AKNotificationItem *)notificationWithName:(NSString *)notificationName;

/*! Does nothing if a notification with the same name already exists. */
- (void)addNotification:(AKNotificationItem *)notificationItem;

@end
