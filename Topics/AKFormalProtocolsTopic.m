/*
 * AKFormalProtocolsTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFormalProtocolsTopic.h"

#import "AKSortUtils.h"
#import "AKDatabase.h"
#import "AKProtocolItem.h"
#import "AKProtocolTopic.h"

@implementation AKFormalProtocolsTopic

#pragma mark - AKTopic methods

- (NSString *)stringToDisplayInTopicBrowser
{
    return AKProtocolsTopicName;
}

- (NSArray *)childTopics
{
    NSMutableArray *columnValues = [NSMutableArray array];
    NSArray *formalProtocols = [self.topicDatabase formalProtocolsForFramework:self.topicFrameworkName];

    for (AKProtocolItem *protocolItem in formalProtocols)
    {
        [columnValues addObject:[AKProtocolTopic topicWithProtocolItem:protocolItem]];
    }

    return [AKSortUtils arrayBySortingArray:columnValues];
}

@end
