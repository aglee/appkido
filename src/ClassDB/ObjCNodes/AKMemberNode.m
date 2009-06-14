//
//  AKMemberNode.m
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKMemberNode.h"

#import "DIGSLog.h"
#import "AKBehaviorNode.h"

@implementation AKMemberNode

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithNodeName:(NSString *)nodeName
    owningFramework:(NSString *)fwName
    owningBehavior:(AKBehaviorNode *)behaviorNode
{
    if ((self = [super initWithNodeName:nodeName owningFramework:fwName]))
    {
        _owningBehavior = [behaviorNode retain];
    }

    return self;
}

- (id)initWithNodeName:(NSString *)nodeName
    owningFramework:(NSString *)fwName
{
    DIGSLogError_NondesignatedInitializer();
    [self release];
    return nil;
}

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

@end
