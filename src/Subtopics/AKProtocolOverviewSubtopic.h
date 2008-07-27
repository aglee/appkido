/*
 * AKClassOverviewSubtopic.h
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorOverviewSubtopic.h"

@class AKProtocolNode;

@interface AKProtocolOverviewSubtopic : AKBehaviorOverviewSubtopic
{
@private
    AKProtocolNode *_protocolNode;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

// convenience method uses the designated initializer
+ (id)subtopicForProtocolNode:(AKProtocolNode *)protocolNode;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

// Designated initializer
- (id)initWithProtocolNode:(AKProtocolNode *)protocolNode;

@end
