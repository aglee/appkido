/*
 * AKInformalProtocolsTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKInformalProtocolsTopic.h"

#import "AKSortUtils.h"
#import "AKDatabase.h"
#import "AKProtocolItem.h"
#import "AKProtocolTopic.h"

@implementation AKInformalProtocolsTopic

#pragma mark -
#pragma mark AKTopic methods

- (NSString *)stringToDisplayInTopicBrowser
{
    return AKInformalProtocolsTopicName;
}

- (NSArray *)childTopics
{
    NSMutableArray *columnValues = [NSMutableArray array];
    NSArray *informalProtocols = [self.topicDatabase informalProtocolsForFrameworkNamed:self.topicFrameworkName];

    for (AKProtocolItem *protocolItem in informalProtocols)
    {
        [columnValues addObject:[AKProtocolTopic topicWithProtocolItem:protocolItem]];
    }

    return [AKSortUtils arrayBySortingArray:columnValues];
}

@end
