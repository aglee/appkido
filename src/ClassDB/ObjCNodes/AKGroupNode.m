/*
 * AKGroupNode.m
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKGroupNode.h"

#import "AKSortUtils.h"

@implementation AKGroupNode


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithNodeName:(NSString *)nodeName
    owningFramework:(AKFramework *)theFramework
{
    if ((self = [super initWithNodeName:nodeName owningFramework:theFramework]))
    {
        _subnodes = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [_subnodes release];

    [super dealloc];
}


#pragma mark -
#pragma mark Getters and setters

- (void)addSubnode:(AKDatabaseNode *)node
{
    [_subnodes addObject:node];
}

- (NSInteger)numberOfSubnodes
{
    return [_subnodes count];
}

- (NSArray *)subnodes
{
    return _subnodes;
}

- (AKDatabaseNode *)subnodeWithName:(NSString *)nodeName
{
    NSEnumerator *subnodeEnum = [_subnodes objectEnumerator];
    AKDatabaseNode *subnode;

    while ((subnode = [subnodeEnum nextObject]))
    {
        if ([[subnode nodeName] isEqualToString:nodeName])
        {
            return subnode;
        }
    }

    // If we got this far, the search failed.
    return nil;
}

@end
