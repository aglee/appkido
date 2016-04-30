/*
 * AKRealMethodsSubtopic.h
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKMembersSubtopic.h"

@class AKBehaviorItem;

@interface AKRealMethodsSubtopic : AKMembersSubtopic
{
@private
    AKBehaviorItem *_behaviorItem;
}

#pragma mark -
#pragma mark Factory methods

+ (instancetype)subtopicForBehaviorItem:(AKBehaviorItem *)behaviorItem
             includeAncestors:(BOOL)includeAncestors;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (instancetype)initWithBehaviorItem:(AKBehaviorItem *)behaviorItem
          includeAncestors:(BOOL)includeAncestors NS_DESIGNATED_INITIALIZER;

#pragma mark -
#pragma mark Getters and setters

@property (NS_NONATOMIC_IOSONLY, readonly, strong) AKBehaviorItem *behaviorItem;

@end
