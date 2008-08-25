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

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)subtopicForBehaviorNode:(AKBehaviorNode *)behaviorNode
    includeAncestors:(BOOL)includeAncestors
{
    return
        [[[self alloc]
            initWithBehaviorNode:behaviorNode
            includeAncestors:includeAncestors] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithBehaviorNode:(AKBehaviorNode *)behaviorNode
    includeAncestors:(BOOL)includeAncestors
{
    if ((self = [super initIncludingAncestors:includeAncestors]))
    {
        _behaviorNode = [behaviorNode retain];
    }

    return self;
}

- (id)initIncludingAncestors:(BOOL)includeAncestors
{
    DIGSLogNondesignatedInitializer();
    [self release];
    return nil;
}

- (void)dealloc
{
    [_behaviorNode release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// AKMembersSubtopic methods
//-------------------------------------------------------------------------

- (AKBehaviorNode *)behaviorNode
{
    return _behaviorNode;
}

@end
