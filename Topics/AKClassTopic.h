/*
 * AKClassTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorTopic.h"

@class AKClassToken;

@interface AKClassTopic : AKBehaviorTopic
{
@private
    AKClassToken *_classToken;
}

#pragma mark - Factory methods

+ (instancetype)topicWithClassToken:(AKClassToken *)classToken;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithClassToken:(AKClassToken *)classToken NS_DESIGNATED_INITIALIZER;

@end
