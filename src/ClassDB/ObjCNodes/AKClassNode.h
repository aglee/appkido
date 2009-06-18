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
 * @class       AKClassNode
 * @abstract    Represents an Objective-C class.
 * @discussion  An AKClassNode represents an Objective-C class, which in
 *              addition to having methods can have categories,
 *              subclasses, and a superclass; can have delegate methods;
 *              can respond to notifications; and can span multiple
 *              frameworks by way of its categories.
 *
 *              The terms "parent class" and "child class" are used when
 *              referring to related nodes rather than "superclass" and
 *              "subclass," to avoid confusion between the class
 *              AKClassNode and the class an AKClassNode represents.
 *
 *              An AKClassNode's -nodeName is the name of the class it
 *              represents.
 */
@interface AKClassNode : AKBehaviorNode
{
@private
    // Represents this class's superclass.
    AKClassNode *_parentClassNode;  // [agl] object cycle.

    // Contains AKClassNodes, each having my class as its parent class.
    NSMutableArray *_childClassNodes;

    // Contains AKCategoryNodes, each representing a category that extends
    // this class.
    NSMutableArray *_categoryNodes;

    // Contains AKMethodNodes, one for each delegate method that has been
    // found in the documentation for this class.
    AKCollectionOfNodes *_indexOfDelegateMethods;

    // Contains AKNotificationNodes, one for each notification that has been
    // found in the documentation for this class.
    AKCollectionOfNodes *_indexOfNotifications;
}

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
#pragma mark Getters and setters -- delegate methods

/** Returns only methods that are in this class's documentation. */
- (NSArray *)documentedDelegateMethods;

- (AKMethodNode *)delegateMethodWithName:(NSString *)methodName;

/*! Does nothing if a delegate method with the same name already exists. */
- (void)addDelegateMethod:(AKMethodNode *)methodNode;


#pragma mark -
#pragma mark Getters and setters -- notifications

/** Returns only methods that are in this class's documentation. */
- (NSArray *)documentedNotifications;

- (AKNotificationNode *)notificationWithName:(NSString *)notificationName;

/*! Does nothing if a notification with the same name already exists. */
- (void)addNotification:(AKNotificationNode *)notificationNode;

@end
