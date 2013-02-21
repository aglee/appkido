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

@property (nonatomic, readonly, weak) AKClassNode *parentClass;


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
