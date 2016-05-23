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
@class AKNotificationToken;
@class AKPropertyToken;
@class AKProtocolToken;

/*!
 * Abstract class. Represents an API construct that can have properties and
 * methods and can receive notifications, i.e. a protocol, class, or category.
 * (I used to think only classes have associated notifications, but it appears
 * the NSAccessibility protocol does as well.)
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
@property (readonly, copy) NSArray *notificationTokens;

#pragma mark - Implemented protocol tokens

- (void)addImplementedProtocol:(AKProtocolToken *)protocolToken;
- (void)addImplementedProtocols:(NSArray *)protocolTokens;

#pragma mark - Property tokens

- (AKPropertyToken *)propertyTokenWithName:(NSString *)propertyName;
/*! Does nothing if a property with the same name already exists. */
- (void)addPropertyToken:(AKPropertyToken *)propertyToken;

#pragma mark - Method tokens

/*! Does not include inherited methods. */
- (AKClassMethodToken *)classMethodWithName:(NSString *)methodName;
/*! Does nothing if a class method with the same name already exists. */
- (void)addClassMethod:(AKClassMethodToken *)methodToken;

- (AKInstanceMethodToken *)instanceMethodWithName:(NSString *)methodName;
/*! Does nothing if an instance method with the same name already exists. */
- (void)addInstanceMethod:(AKInstanceMethodToken *)methodToken;

#pragma mark - Notification tokens

- (AKNotificationToken *)notificationWithName:(NSString *)notificationName;
/*! Does nothing if a notification with the same name already exists. */
- (void)addNotification:(AKNotificationToken *)notificationToken;

@end
