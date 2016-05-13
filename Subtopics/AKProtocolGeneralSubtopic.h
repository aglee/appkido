/*
 * AKProtocolGeneralSubtopic.h
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorGeneralSubtopic.h"

@class AKProtocolToken;

@interface AKProtocolGeneralSubtopic : AKBehaviorGeneralSubtopic
{
@private
    AKProtocolToken *_protocolToken;
}

#pragma mark - Factory methods

+ (instancetype)subtopicForProtocolToken:(AKProtocolToken *)protocolToken;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithProtocolToken:(AKProtocolToken *)protocolToken NS_DESIGNATED_INITIALIZER;

@end
