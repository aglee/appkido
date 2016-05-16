/*
 * AKClassTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorTopic.h"

@class AKClassToken;

@interface AKClassTopic : AKBehaviorTopic

- (instancetype)initWithClassToken:(AKClassToken *)classToken NS_DESIGNATED_INITIALIZER;

@end
