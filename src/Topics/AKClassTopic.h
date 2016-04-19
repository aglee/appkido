/*
 * AKClassTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorTopic.h"

@class AKClassNode;

@interface AKClassTopic : AKBehaviorTopic
{
@private
    AKClassNode *_classNode;
}

#pragma mark -
#pragma mark Factory methods

+ (instancetype)topicWithClassNode:(AKClassNode *)classNode;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (instancetype)initWithClassNode:(AKClassNode *)classNode NS_DESIGNATED_INITIALIZER;

@end
