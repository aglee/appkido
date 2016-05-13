/*
 * AKProtocolGeneralSubtopic.m
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKProtocolGeneralSubtopic.h"

#import "DIGSLog.h"
#import "AKProtocolToken.h"

@implementation AKProtocolGeneralSubtopic

#pragma mark - Factory methods

+ (instancetype)subtopicForProtocolToken:(AKProtocolToken *)protocolToken
{
    return [[self alloc] initWithProtocolToken:protocolToken];
}

#pragma mark - Init/awake/dealloc

- (instancetype)initWithProtocolToken:(AKProtocolToken *)protocolToken
{
    if ((self = [super init]))
    {
        _protocolToken = protocolToken;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithProtocolToken:nil];
}


#pragma mark - AKBehaviorGeneralSubtopic methods

- (AKBehaviorToken *)behaviorToken
{
    return _protocolToken;
}

@end
