//
// AKClassNode.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKBehaviorNode.h"

@class AKPropertyNode;
@class AKNotificationNode;
@class AKCategoryNode;
@class AKCollectionOfNodes;

/*!
 * Represents an Objective-C class, which in addition to having methods can have
 * categories, subclasses, and a superclass; can have delegate methods; can
 * respond to notifications; and can span multiple frameworks by way of its
 * categories.
 *
 * We use the terms "parent class" and "child class" rather than "superclass"
 * and "subclass", to avoid confusion.
 */
@interface AKClassNode : AKBehaviorNode
{
@private
//ARC    AKClassNode *_parentClass;
    __unsafe_unretained AKClassNode *_parentClass;

    // Elements are strings.
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

@property (nonatomic, readonly, unsafe_unretained) AKClassNode *parentClass;

#pragma mark -
#pragma mark Getters and setters -- general

- (AKClassNode *)parentClass;

// Handles case of node having existing parent.
- (void)addChildClass:(AKClassNode *)node;
- (void)removeChildClass:(AKClassNode *)node;
- (NSArray *)childClasses;
- (NSSet *)descendantClasses;
- (BOOL)hasChildClasses;

- (void)addCategory:(AKCategoryNode *)node;
- (AKCategoryNode *)categoryNamed:(NSString *)catName;
- (NSArray *)allCategories;

#pragma mark -
#pragma mark Getters and setters -- multiple owning frameworks

/*!
 * Names of all frameworks the class belongs to. The first element of the
 * returned array is the name of the framework the class was declared in (its
 * owningFramework). After that, the order of the array is the order in which it
 * was discovered that the class belongs to the framework.
 */
- (NSArray *)namesOfAllOwningFrameworks;

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

/*! Returns only methods that are in this class's documentation. */
- (NSArray *)documentedDelegateMethods;

- (AKMethodNode *)delegateMethodWithName:(NSString *)methodName;

/*! Does nothing if a delegate method with the same name already exists. */
- (void)addDelegateMethod:(AKMethodNode *)methodNode;

#pragma mark -
#pragma mark Getters and setters -- notifications

/*! Returns only methods that are in this class's documentation. */
- (NSArray *)documentedNotifications;

- (AKNotificationNode *)notificationWithName:(NSString *)notificationName;

/*! Does nothing if a notification with the same name already exists. */
- (void)addNotification:(AKNotificationNode *)notificationNode;

@end
