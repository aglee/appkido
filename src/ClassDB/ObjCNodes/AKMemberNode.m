//
//  AKMemberNode.m
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKMemberNode.h"

#import "AKBehaviorNode.h"

@implementation AKMemberNode

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (void)dealloc
{
    [_owningBehavior release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (AKBehaviorNode *)owningBehavior
{
    return _owningBehavior;
}

- (void)setOwningBehavior:(AKBehaviorNode *)behaviorNode
{
    [behaviorNode retain];
    [_owningBehavior release];
    _owningBehavior = behaviorNode;
}

@end
