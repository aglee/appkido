//
//  AKGroupedNode.m
//  AppKiDo
//
//  Created by Andy Lee on 4/25/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKGroupedNode.h"

#import "DIGSLog.h"

@implementation AKGroupedNode

@synthesize groupName = _groupName;

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithNodeName:(NSString *)nodeName
       owningFramework:(AKFramework *)theFramework
             groupName:(NSString *)groupName
{
    if ((self = [super initWithNodeName:nodeName owningFramework:theFramework]))
    {
        _groupName = groupName;
    }

    return self;
}

- (id)initWithNodeName:(NSString *)nodeName owningFramework:(AKFramework *)theFramework
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}


#pragma mark -
#pragma mark Getters and setters

- (NSString *)groupName
{
    return _groupName;
}

@end
