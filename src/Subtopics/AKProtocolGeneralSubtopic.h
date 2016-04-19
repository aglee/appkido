/*
 * AKProtocolGeneralSubtopic.h
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorGeneralSubtopic.h"

@class AKProtocolNode;

@interface AKProtocolGeneralSubtopic : AKBehaviorGeneralSubtopic
{
@private
    AKProtocolNode *_protocolNode;
}

#pragma mark -
#pragma mark Factory methods

+ (instancetype)subtopicForProtocolNode:(AKProtocolNode *)protocolNode;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (instancetype)initWithProtocolNode:(AKProtocolNode *)protocolNode NS_DESIGNATED_INITIALIZER;

@end
