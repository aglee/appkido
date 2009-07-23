/*
 * AKGroupNodeSubtopic.m
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKGroupNodeSubtopic.h"

#import "DIGSLog.h"

#import "AKSortUtils.h"
#import "AKFileSection.h"
#import "AKGlobalsNode.h"
#import "AKGroupNode.h"
#import "AKNodeDoc.h"

@implementation AKGroupNodeSubtopic


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithGroupNode:(AKGroupNode *)groupNode
{
    if ((self = [super init]))
    {
        _groupNode = [groupNode retain];
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    [self release];
    return nil;
}

- (void)dealloc
{
    [_groupNode release];

    [super dealloc];
}


#pragma mark -
#pragma mark AKSubtopic methods

- (NSString *)subtopicName
{
    return [_groupNode nodeName];
}

- (void)populateDocList:(NSMutableArray *)docList
{
    NSEnumerator *subnodesEnum =
        [[AKSortUtils arrayBySortingArray:[_groupNode subnodes]]
            objectEnumerator];
    AKGlobalsNode *globalsNode;

    while ((globalsNode = [subnodesEnum nextObject]))
    {
        AKDoc *newDoc =
            [[[AKNodeDoc alloc] initWithNode:globalsNode] autorelease];

        [docList addObject:newDoc];
    }
}

@end
