//
// AKBehaviorToken.h
//
// Created by Andy Lee on Sun Jun 30 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKToken.h"

@class AKBehaviorToken;
@class AKClassMethodToken;
@class AKInstanceMethodToken;
@class AKMemberToken;
@class AKPropertyToken;
@class AKProtocolToken;

/*!
 * Abstract class. Represents an API construct that can have properties and
 * methods, i.e. a protocol, class, or category.
 *
 * Note: unlike other database items, class and protocol items can be
 * initialized with nil as their owning framework name. The reason is that when
 * we are constructing the database, we may encounter a reference to a class or
 * protocol before it has been declared. For example, we may encounter a
 * category (and thus the name of its owning class) before we encounter the
 * owning class's declaration. Or we may encounter a protocol in a class's list
 * of protocols before we've encountered its @protocol declaration.
 */
@interface AKBehaviorToken : AKToken

@property (assign, readonly) BOOL isClassToken;
/*! Includes protocols implemented by virtue of inheritance. */
@property (readonly, copy) NSArray *implementedProtocols;
@property (readonly, copy) NSArray *instanceMethodTokens;
@property (readonly, copy) NSArray *propertyTokens;
@property (readonly, copy) NSArray *classMethodTokens;

#pragma mark - Getters and setters -- properties

- (void)addImplementedProtocol:(AKProtocolToken *)protocolToken;
- (void)addImplementedProtocols:(NSArray *)protocolTokens;

- (AKPropertyToken *)propertyTokenWithName:(NSString *)propertyName;
/*! Does nothing if a property with the same name already exists. */
- (void)addPropertyToken:(AKPropertyToken *)propertyToken;

#pragma mark - Getters and setters -- class methods

/*! Does not include inherited methods. */
- (AKClassMethodToken *)classMethodWithName:(NSString *)methodName;
/*! Does nothing if a class method with the same name already exists. */
- (void)addClassMethod:(AKClassMethodToken *)methodToken;

#pragma mark - Getters and setters -- instance methods

- (AKInstanceMethodToken *)instanceMethodWithName:(NSString *)methodName;
/*! Does nothing if an instance method with the same name already exists. */
- (void)addInstanceMethod:(AKInstanceMethodToken *)methodToken;

@end
