/*
 * AKFormalProtocolsTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFormalProtocolsTopic.h"
#import "AKSortUtils.h"
#import "AKDatabase.h"
#import "AKProtocolToken.h"
#import "AKProtocolTopic.h"

@implementation AKFormalProtocolsTopic

#pragma mark - AKTopic methods

- (NSArray *)_arrayWithChildTopics
{
	NSMutableArray *columnValues = [NSMutableArray array];
	NSArray *formalProtocols = [self.database formalProtocolsForFramework:self.frameworkName];

	for (AKProtocolToken *protocolToken in formalProtocols) {
		[columnValues addObject:[[AKProtocolTopic alloc] initWithProtocolToken:protocolToken]];
	}

	return [AKSortUtils arrayBySortingArray:columnValues];
}

#pragma mark - <AKNamed> methods

- (NSString *)name
{
	return AKProtocolsTopicName;
}

@end
