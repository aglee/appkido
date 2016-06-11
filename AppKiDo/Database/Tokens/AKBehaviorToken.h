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
 */
@interface AKBehaviorToken : AKToken

@property (assign, readonly) BOOL isClassToken;
@property (assign) BOOL isDelegateProtocolToken;
/*! Includes inherited protocols. */
@property (readonly, copy) NSArray *adoptedProtocolTokens;
@property (readonly, copy) NSArray *instanceMethodTokens;
@property (readonly, copy) NSArray *propertyTokens;
@property (readonly, copy) NSArray *classMethodTokens;
@property (readonly, copy) NSArray *notificationTokens;
@property (readonly, copy) NSArray *dataTypeTokens;
@property (readonly, copy) NSArray *constantTokens;

#pragma mark - Adopted protocol tokens

- (void)addAdoptedProtocol:(AKProtocolToken *)protocolToken;

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

#pragma mark - Data types tokens

- (void)addDataTypeToken:(AKToken *)token;
- (AKToken *)dataTypeTokenWithName:(NSString *)name;

#pragma mark - Constants tokens

- (void)addConstantToken:(AKToken *)token;
- (AKToken *)constantTokenWithName:(NSString *)name;

#pragma mark - Notification tokens

- (AKNotificationToken *)notificationWithName:(NSString *)notificationName;
/*! Does nothing if a notification with the same name already exists. */
- (void)addNotification:(AKNotificationToken *)notificationToken;

@end
