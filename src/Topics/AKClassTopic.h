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

+ (id)topicWithClassNode:(AKClassNode *)classNode;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithClassNode:(AKClassNode *)classNode;

@end
