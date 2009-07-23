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


#pragma mark -
#pragma mark AKTopic methods

- (NSString *)stringToDisplayInTopicBrowser
{
    return AKProtocolsTopicName;
}

- (NSArray *)childTopics
{
    NSMutableArray *columnValues = [NSMutableArray array];
    NSEnumerator *en =
        [[[_topicFramework fwDatabase]
            formalProtocolsForFrameworkNamed:[_topicFramework frameworkName]] objectEnumerator];
    AKProtocolNode *protocolNode;

    while ((protocolNode = [en nextObject]))
    {
        [columnValues addObject:[AKProtocolTopic topicWithProtocolNode:protocolNode]];
    }

    return [AKSortUtils arrayBySortingArray:columnValues];
}

@end
