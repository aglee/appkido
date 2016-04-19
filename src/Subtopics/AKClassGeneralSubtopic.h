/*
 * AKClassGeneralSubtopic.h
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorGeneralSubtopic.h"

@class AKClassNode;

@interface AKClassGeneralSubtopic : AKBehaviorGeneralSubtopic
{
@private
    AKClassNode *_classNode;
}

#pragma mark -
#pragma mark Factory methods

+ (instancetype)subtopicForClassNode:(AKClassNode *)classNode;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (instancetype)initWithClassNode:(AKClassNode *)classNode NS_DESIGNATED_INITIALIZER;

@end
