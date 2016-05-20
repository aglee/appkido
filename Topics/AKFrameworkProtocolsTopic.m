//
//  AKFrameworkProtocolsTopic.m
//  AppKiDo
//
//  Created by Andy Lee on 5/20/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKFrameworkProtocolsTopic.h"
#import "AKFramework.h"
#import "AKNamedObjectGroup.h"
#import "AKProtocolToken.h"
#import "AKProtocolTopic.h"

@implementation AKFrameworkProtocolsTopic

#pragma mark - AKTopic methods

- (NSString *)pathInTopicBrowser
{
	return [NSString stringWithFormat:@"%@%@%@%@",
			AKTopicBrowserPathSeparator, self.framework.name,
			AKTopicBrowserPathSeparator, self.framework.protocolsGroup.name];
}

// One child topic for each protocol in the framework.
- (NSArray *)_arrayWithChildTopics
{
	NSMutableArray *childTopics = [NSMutableArray array];

	for (AKProtocolToken *protocolToken in self.framework.protocolsGroup.sortedObjects) {
		AKProtocolTopic *protocolTopic = [[AKProtocolTopic alloc] initWithProtocolToken:protocolToken];
		[childTopics addObject:protocolTopic];
	}

	return childTopics;
}

#pragma mark - <AKNamed> methods

- (NSString *)name
{
	return self.framework.protocolsGroup.name;
}

@end
