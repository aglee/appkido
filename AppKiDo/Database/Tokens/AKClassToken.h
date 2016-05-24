//
// AKClassToken.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKBehaviorToken.h"

@class AKBindingToken;
@class AKCategoryToken;
@class AKMethodToken;
@class AKPropertyToken;

/*!
 * Represents an Objective-C class, which in addition to having methods can have
 * a superclass, subclasses, categories, and delegate methods; and can span
 * multiple frameworks by way of its categories.
 */
@interface AKClassToken : AKBehaviorToken

@property (readonly, weak) AKClassToken *parentClass;
@property (readonly, copy) NSArray *childClasses;
@property (readonly, copy) NSSet *descendantClasses;
@property (readonly, copy) NSArray *allCategories;
@property (readonly, copy) NSArray *delegateMethodTokens;

/*!
 * Names of all frameworks the class belongs to. The first element of the
 * returned array is the name of the framework the class was declared in (its
 * owningFramework). After that, the order of the array is the order in which it
 * was discovered that the class belongs to the framework.
 */
@property (readonly, copy) NSArray *namesOfAllOwningFrameworks;

#pragma mark - Subclass tokens

- (void)addChildClass:(AKClassToken *)classToken;
- (void)removeChildClass:(AKClassToken *)classToken;

#pragma mark - Category tokens

- (void)addCategory:(AKCategoryToken *)token;
- (AKCategoryToken *)categoryNamed:(NSString *)name;

#pragma mark - Bindings tokens

- (void)addBindingToken:(AKBindingToken *)token;
- (AKBindingToken *)bindingTokenNamed:(NSString *)name;
- (NSArray *)bindingTokens;

#pragma mark - Owning frameworks

- (void)setMainFrameworkName:(NSString *)frameworkName;  //TODO: Handle the multi-frameworkness of classes.

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

#pragma mark - Delegate method tokens

- (AKMethodToken *)delegateMethodWithName:(NSString *)methodName;

/*! Does nothing if a delegate method with the same name already exists. */
- (void)addDelegateMethod:(AKMethodToken *)methodToken;

@end
