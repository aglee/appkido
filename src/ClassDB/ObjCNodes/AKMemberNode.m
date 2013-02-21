//
//  AKMemberNode.m
//  AppKiDo
//
//  Created by Andy Lee on 7/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKMemberNode.h"

#import "DIGSLog.h"
#import "AKBehaviorNode.h"

@implementation AKMemberNode

@synthesize owningBehavior = _owningBehavior;

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithNodeName:(NSString *)nodeName
       owningFramework:(AKFramework *)theFramework
        owningBehavior:(AKBehaviorNode *)behaviorNode
{
    if ((self = [super initWithNodeName:nodeName owningFramework:theFramework]))
    {
        _owningBehavior = behaviorNode;
    }

    return self;
}

- (id)initWithNodeName:(NSString *)nodeName owningFramework:(AKFramework *)theFramework
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}


@end
