/*
 * AKProtocolGeneralSubtopic.h
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorGeneralSubtopic.h"

@class AKProtocolItem;

@interface AKProtocolGeneralSubtopic : AKBehaviorGeneralSubtopic
{
@private
    AKProtocolItem *_protocolItem;
}

#pragma mark - Factory methods

+ (instancetype)subtopicForProtocolItem:(AKProtocolItem *)protocolItem;

#pragma mark - Init/awake/dealloc

/*! Designated initializer. */
- (instancetype)initWithProtocolItem:(AKProtocolItem *)protocolItem NS_DESIGNATED_INITIALIZER;

@end
