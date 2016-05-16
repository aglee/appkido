/*
 * AKProtocolTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorTopic.h"

@class AKProtocolToken;

@interface AKProtocolTopic : AKBehaviorTopic

#pragma mark - Init/awake/dealloc

- (instancetype)initWithProtocolToken:(AKProtocolToken *)protocolToken NS_DESIGNATED_INITIALIZER;

@end
