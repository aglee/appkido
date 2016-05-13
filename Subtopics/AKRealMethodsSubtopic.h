/*
 * AKRealMethodsSubtopic.h
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKMembersSubtopic.h"

@class AKBehaviorToken;

@interface AKRealMethodsSubtopic : AKMembersSubtopic
{
@private
    AKBehaviorToken *_behaviorToken;
}

#pragma mark - Factory methods

+ (instancetype)subtopicForBehaviorToken:(AKBehaviorToken *)behaviorToken
             includeAncestors:(BOOL)includeAncestors;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithBehaviorToken:(AKBehaviorToken *)behaviorToken
          includeAncestors:(BOOL)includeAncestors NS_DESIGNATED_INITIALIZER;

#pragma mark - Getters and setters

@property (NS_NONATOMIC_IOSONLY, readonly, strong) AKBehaviorToken *behaviorToken;

@end
