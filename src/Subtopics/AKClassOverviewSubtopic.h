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

#pragma mark -
#pragma mark Factory methods

+ (id)subtopicForClassNode:(AKClassNode *)classNode;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithClassNode:(AKClassNode *)classNode;

@end
