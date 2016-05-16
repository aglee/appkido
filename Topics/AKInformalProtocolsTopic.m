/*
 * AKInformalProtocolsTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKInformalProtocolsTopic.h"

#import "AKSortUtils.h"
#import "AKDatabase.h"
#import "AKProtocolToken.h"
#import "AKProtocolTopic.h"

@implementation AKInformalProtocolsTopic

#pragma mark - AKTopic methods

- (NSString *)name
{
    return AKInformalProtocolsTopicName;
}

- (NSArray *)childTopics
{
    NSMutableArray *columnValues = [NSMutableArray array];
    NSArray *informalProtocols = [self.topicDatabase informalProtocolsForFramework:self.topicFrameworkName];

    for (AKProtocolToken *protocolToken in informalProtocols)
    {
        [columnValues addObject:[[AKProtocolTopic alloc] initWithProtocolToken:protocolToken]];
    }

    return [AKSortUtils arrayBySortingArray:columnValues];
}

@end
