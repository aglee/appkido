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

@property (readonly, weak) AKClassToken *superclassToken;
@property (readonly, copy) NSArray *subclassTokens;
@property (readonly, copy) NSSet *descendantClassTokens;
@property (readonly, copy) NSArray *categoryTokensImmediateOnly;
@property (readonly, copy) NSArray *categoryTokensIncludingInherited;
@property (readonly, assign) BOOL hasDelegate;
@property (readonly, copy) NSArray *delegateMethodTokens;
@property (readonly, copy) NSArray *delegateProtocolTokens;
@property (readonly, copy) NSArray *bindingTokens;

#pragma mark - Subclass tokens

- (void)addSubclassToken:(AKClassToken *)classToken;
- (void)removeSubclassToken:(AKClassToken *)classToken;

#pragma mark - Category tokens

- (void)addCategoryToken:(AKCategoryToken *)token;
- (AKCategoryToken *)categoryTokenWithName:(NSString *)name;

#pragma mark - Bindings tokens

- (void)addBindingToken:(AKBindingToken *)bindingToken;
- (AKBindingToken *)bindingTokenWithName:(NSString *)name;

#pragma mark - Delegate method tokens

- (void)addDelegateProtocolToken:(AKProtocolToken *)delegateProtocolToken;

@end
