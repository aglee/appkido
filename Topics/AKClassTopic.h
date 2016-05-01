/*
 * AKClassTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorTopic.h"

@class AKClassItem;

@interface AKClassTopic : AKBehaviorTopic
{
@private
    AKClassItem *_classItem;
}

#pragma mark -
#pragma mark Factory methods

+ (instancetype)topicWithClassItem:(AKClassItem *)classItem;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (instancetype)initWithClassItem:(AKClassItem *)classItem NS_DESIGNATED_INITIALIZER;

@end
