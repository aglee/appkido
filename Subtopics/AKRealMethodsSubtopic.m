/*
 * AKRealMethodsSubtopic.m
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKRealMethodsSubtopic.h"
#import "DIGSLog.h"
#import "AKClassToken.h"
#import "AKMethodToken.h"

@implementation AKRealMethodsSubtopic

#pragma mark - Factory methods

+ (instancetype)subtopicForBehaviorToken:(AKBehaviorToken *)behaviorToken
             includeAncestors:(BOOL)includeAncestors
{
    return [[self alloc] initWithBehaviorToken:behaviorToken
                              includeAncestors:includeAncestors];
}

#pragma mark - Init/awake/dealloc

- (instancetype)initWithBehaviorToken:(AKBehaviorToken *)behaviorToken
          includeAncestors:(BOOL)includeAncestors
{
    if ((self = [super initIncludingAncestors:includeAncestors]))
    {
        _behaviorToken = behaviorToken;
    }

    return self;
}

- (instancetype)initIncludingAncestors:(BOOL)includeAncestors
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithBehaviorToken:nil includeAncestors:NO];
}


#pragma mark - AKMembersSubtopic methods

- (AKBehaviorToken *)behaviorToken
{
    return _behaviorToken;
}

@end
