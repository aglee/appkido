/*
 * AKClassGeneralSubtopic.h
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorGeneralSubtopic.h"

@class AKClassToken;

@interface AKClassGeneralSubtopic : AKBehaviorGeneralSubtopic

#pragma mark - Factory methods

+ (instancetype)subtopicForClassToken:(AKClassToken *)classToken;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithClassToken:(AKClassToken *)classToken NS_DESIGNATED_INITIALIZER;

@end
