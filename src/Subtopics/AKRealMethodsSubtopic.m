/*
 * AKRealMethodsSubtopic.m
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKRealMethodsSubtopic.h"

#import "DIGSLog.h"

#import "AKClassNode.h"
#import "AKMethodNode.h"
#import "AKMemberDoc.h"

@implementation AKRealMethodsSubtopic

#pragma mark -
#pragma mark Factory methods

+ (instancetype)subtopicForBehaviorNode:(AKBehaviorNode *)behaviorNode
             includeAncestors:(BOOL)includeAncestors
{
    return [[self alloc] initWithBehaviorNode:behaviorNode
                              includeAncestors:includeAncestors];
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithBehaviorNode:(AKBehaviorNode *)behaviorNode
          includeAncestors:(BOOL)includeAncestors
{
    if ((self = [super initIncludingAncestors:includeAncestors]))
    {
        _behaviorNode = behaviorNode;
    }

    return self;
}

- (instancetype)initIncludingAncestors:(BOOL)includeAncestors
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithBehaviorNode:nil includeAncestors:NO];
}


#pragma mark -
#pragma mark AKMembersSubtopic methods

- (AKBehaviorNode *)behaviorNode
{
    return _behaviorNode;
}

@end
