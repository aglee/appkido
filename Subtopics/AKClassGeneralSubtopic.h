/*
 * AKClassGeneralSubtopic.h
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorGeneralSubtopic.h"

@class AKClassItem;

@interface AKClassGeneralSubtopic : AKBehaviorGeneralSubtopic

#pragma mark - Factory methods

+ (instancetype)subtopicForClassItem:(AKClassItem *)classItem;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithClassItem:(AKClassItem *)classItem NS_DESIGNATED_INITIALIZER;

@end
