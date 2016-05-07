/*
 * AKProtocolTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorTopic.h"

@class AKProtocolItem;

@interface AKProtocolTopic : AKBehaviorTopic
{
@private
    AKProtocolItem *_protocolItem;
}

#pragma mark - Factory methods

+ (instancetype)topicWithProtocolItem:(AKProtocolItem *)protocolItem;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithProtocolItem:(AKProtocolItem *)protocolItem NS_DESIGNATED_INITIALIZER;

@end
