/*
 * AKFrameworkTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"

@class AKFramework;

/*!
 * Represents a framework.
 */
@interface AKFrameworkTopic : AKTopic

@property (copy, readonly) AKFramework *framework;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithFramework:(AKFramework *)framework NS_DESIGNATED_INITIALIZER;

@end
