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

- (NSArray *)_arrayWithChildTopics
{
	NSMutableArray *columnValues = [NSMutableArray array];
	NSArray *informalProtocols = [self.database informalProtocolsForFramework:self.frameworkName];

	for (AKProtocolToken *protocolToken in informalProtocols) {
		[columnValues addObject:[[AKProtocolTopic alloc] initWithProtocolToken:protocolToken]];
	}

	return [AKSortUtils arrayBySortingArray:columnValues];
}

#pragma mark - <AKNamed> methods

- (NSString *)name
{
	return AKInformalProtocolsTopicName;
}

@end
