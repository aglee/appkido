/*
 * AKFormalProtocolsTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFormalProtocolsTopic.h"

#import "AKSortUtils.h"
#import "AKDatabase.h"
#import "AKProtocolNode.h"
#import "AKProtocolTopic.h"

@implementation AKFormalProtocolsTopic

//-------------------------------------------------------------------------
// AKTopic methods
//-------------------------------------------------------------------------

- (NSString *)stringToDisplayInTopicBrowser
{
    return AKProtocolsTopicName;
}

- (NSArray *)childTopics
{
    NSMutableArray *columnValues = [NSMutableArray array];
    NSEnumerator *en =
        [[[AKDatabase defaultDatabase]
            formalProtocolsForFramework:_topicFramework]
            objectEnumerator];
    AKProtocolNode *protocolNode;

    while ((protocolNode = [en nextObject]))
    {
        [columnValues addObject:
            [AKProtocolTopic withProtocolNode:protocolNode]];
    }

    return [AKSortUtils arrayBySortingArray:columnValues];
}

@end
