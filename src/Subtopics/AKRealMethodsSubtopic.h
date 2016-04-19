/*
 * AKRealMethodsSubtopic.h
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKMembersSubtopic.h"

@class AKBehaviorNode;

@interface AKRealMethodsSubtopic : AKMembersSubtopic
{
@private
    AKBehaviorNode *_behaviorNode;
}

#pragma mark -
#pragma mark Factory methods

+ (instancetype)subtopicForBehaviorNode:(AKBehaviorNode *)behaviorNode
             includeAncestors:(BOOL)includeAncestors;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (instancetype)initWithBehaviorNode:(AKBehaviorNode *)behaviorNode
          includeAncestors:(BOOL)includeAncestors NS_DESIGNATED_INITIALIZER;

#pragma mark -
#pragma mark Getters and setters

@property (NS_NONATOMIC_IOSONLY, readonly, strong) AKBehaviorNode *behaviorNode;

@end
