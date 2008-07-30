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
    AKBehaviorNode *_behaviorNode;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

// convenience method uses the designated initializer
+ (id)subtopicForBehaviorNode:(AKBehaviorNode *)behaviorNode
    includeAncestors:(BOOL)includeAncestors;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

// Designated initializer
- (id)initWithBehaviorNode:(AKBehaviorNode *)behaviorNode
    includeAncestors:(BOOL)includeAncestors;

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (AKBehaviorNode *)behaviorNode;

@end

