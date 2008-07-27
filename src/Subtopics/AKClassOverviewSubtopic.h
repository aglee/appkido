/*
 * AKClassOverviewSubtopic.h
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorOverviewSubtopic.h"

@class AKClassNode;

@interface AKClassOverviewSubtopic : AKBehaviorOverviewSubtopic
{
@private
    AKClassNode *_classNode;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

// convenience method uses the designated initializer
+ (id)subtopicForClassNode:(AKClassNode *)classNode;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

// Designated initializer
- (id)initWithClassNode:(AKClassNode *)classNode;

@end
