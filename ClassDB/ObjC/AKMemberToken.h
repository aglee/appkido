//
//  AKMemberToken.h
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKToken.h"

@class AKBehaviorToken;

/*!
 * Represents a member (as in the term "member function") of a behavior.
 * Stretches the concept of "member" slightly.  Used not only for properties and
 * methods, but also for bindings, delegate methods and notifications.
 */
@interface AKMemberToken : AKToken

@property (nonatomic, readonly, weak) AKBehaviorToken *owningBehavior;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithToken:(DSAToken *)token owningBehavior:(AKBehaviorToken *)behaviorToken NS_DESIGNATED_INITIALIZER;

@end
