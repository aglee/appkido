//
// AKClassToken.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKBehaviorToken.h"

@class AKBindingToken;
@class AKCategoryToken;
@class AKCollectionOfItems;
@class AKNotificationToken;
@class AKPropertyToken;

/*!
 * Represents an Objective-C class, which in addition to having methods can have
 * categories, subclasses, and a superclass; can have delegate methods; can
 * respond to notifications; and can span multiple frameworks by way of its
 * categories.
 *
 * We use the terms "parent class" and "child class" rather than "superclass"
 * and "subclass", to avoid confusion.
 */
@interface AKClassToken : AKBehaviorToken
{
@private
	NSMutableArray *_namesOfAllOwningFrameworks;
	NSMutableArray *_childClassTokens;  // Contains AKClassTokens.
	NSMutableArray *_categoryTokens;  // Contains AKCategoryTokens.
	AKCollectionOfItems *_indexOfDelegateMethods;  // Contains AKMethodTokens.
	AKCollectionOfItems *_indexOfNotifications;  // Contains AKNotificationTokens.
	AKCollectionOfItems *_indexOfBindings;  // Contains AKBindingTokens.
}

@property (readonly, weak) AKClassToken *parentClass;
@property (readonly, copy) NSArray *childClasses;
@property (readonly, copy) NSSet *descendantClasses;
@property (readonly) BOOL hasChildClasses;
@property (readonly, copy) NSArray *allCategories;
@property (readonly, copy) NSArray *documentedDelegateMethods;
@property (readonly, copy) NSArray *documentedNotifications;

/*!
 * Names of all frameworks the class belongs to. The first element of the
 * returned array is the name of the framework the class was declared in (its
 * owningFramework). After that, the order of the array is the order in which it
 * was discovered that the class belongs to the framework.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *namesOfAllOwningFrameworks;

#pragma mark - Getters and setters -- general

- (void)addChildClass:(AKClassToken *)classToken;
- (void)removeChildClass:(AKClassToken *)classToken;

- (void)addCategory:(AKCategoryToken *)categoryToken;
- (AKCategoryToken *)categoryNamed:(NSString *)catName;

- (void)addBindingToken:(AKBindingToken *)bindingToken;
- (AKBindingToken *)bindingTokenNamed:(NSString *)bindingName;
- (NSArray *)documentedBindings;

#pragma mark - Getters and setters -- multiple owning frameworks

- (BOOL)isOwnedByFramework:(NSString *)frameworkName;

//TODO: Commenting out, come back later.
//- (AKFileSection *)documentationAssociatedWithFramework:(NSString *)frameworkName;
//
///*!
// * It's possible for a class to belong to multiple frameworks. The usual example
// * I give is NSString, which is declared in Foundation and also has methods in
// * AppKit by way of a category. We keep track of all the frameworks that "own" a
// * class, and all the doc files that are associated with each framework.
// */
//- (void)associateDocumentation:(AKFileSection *)fileSection
//            withFramework:(NSString *)frameworkName;

#pragma mark - Getters and setters -- delegate methods

- (AKMethodToken *)delegateMethodWithName:(NSString *)methodName;

/*! Does nothing if a delegate method with the same name already exists. */
- (void)addDelegateMethod:(AKMethodToken *)methodToken;

#pragma mark - Getters and setters -- notifications

- (AKNotificationToken *)notificationWithName:(NSString *)notificationName;

/*! Does nothing if a notification with the same name already exists. */
- (void)addNotification:(AKNotificationToken *)notificationToken;




- (void)setMainFrameworkName:(NSString *)frameworkName;  //TODO: Fix the multi-frameworkness of class items.


#pragma mark - KLUDGES

@property (copy) NSString *fallbackTokenName;


@end
