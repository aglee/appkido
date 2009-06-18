//
//  AKGroupedNode.m
//  AppKiDo
//
//  Created by Andy Lee on 4/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKGroupedNode.h"

#import "DIGSLog.h"

@implementation AKGroupedNode

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithNodeName:(NSString *)nodeName
    owningFramework:(AKFramework *)theFramework
    groupName:(NSString *)groupName
{
    if ((self = [super initWithNodeName:nodeName owningFramework:theFramework]))
    {
        _groupName = [groupName retain];
    }

    return self;
}

- (id)initWithNodeName:(NSString *)nodeName
    owningFramework:(AKFramework *)theFramework
{
    DIGSLogError_NondesignatedInitializer();
    [self release];
    return nil;
}

- (void)dealloc
{
    [_groupName release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSString *)groupName
{
    return _groupName;
}

@end
