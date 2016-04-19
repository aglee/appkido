/*
 * AKGroupNodeSubtopic.m
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKGroupNodeSubtopic.h"

#import "AKGroupNode.h"

@implementation AKGroupNodeSubtopic

@synthesize groupNode = _groupNode;

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithGroupNode:(AKGroupNode *)groupNode
{
    if ((self = [super init]))
    {
        _groupNode = groupNode;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithGroupNode:nil];
}


#pragma mark -
#pragma mark AKSubtopic methods

- (NSString *)subtopicName
{
    return _groupNode.nodeName;
}

@end
