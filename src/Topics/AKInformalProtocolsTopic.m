/*
 * AKInformalProtocolsTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKInformalProtocolsTopic.h"

#import "AKSortUtils.h"
#import "AKDatabase.h"
#import "AKProtocolNode.h"
#import "AKProtocolTopic.h"

@implementation AKInformalProtocolsTopic

//-------------------------------------------------------------------------
// AKTopic methods
//-------------------------------------------------------------------------

- (NSString *)stringToDisplayInTopicBrowser
{
    return AKInformalProtocolsTopicName;
}

- (NSArray *)childTopics
{
    NSMutableArray *columnValues = [NSMutableArray array];
    NSEnumerator *en =
        [[_database informalProtocolsForFramework:_topicFramework]
            objectEnumerator];
    AKProtocolNode *protocolNode;

    while ((protocolNode = [en nextObject]))
    {
        [columnValues addObject:
            [AKProtocolTopic topicWithProtocolNode:protocolNode inDatabase:_database]];
    }

    return [AKSortUtils arrayBySortingArray:columnValues];
}

@end
