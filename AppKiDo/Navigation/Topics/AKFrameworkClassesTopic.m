//
//  AKFrameworkClassesTopic.m
//  AppKiDo
//
//  Created by Andy Lee on 6/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKFrameworkClassesTopic.h"
#import "AKClassToken.h"
#import "AKClassTopicUnderFrameworkTopic.h"
#import "AKFramework.h"
#import "AKNamedObjectGroup.h"

@implementation AKFrameworkClassesTopic

#pragma mark - AKTopic methods

- (NSString *)pathInTopicBrowser
{
	return [NSString stringWithFormat:@"%@%@%@%@",
			AKTopicBrowserPathSeparator, self.framework.name,
			AKTopicBrowserPathSeparator, self.framework.classesGroup.name];
}

- (NSArray *)_arrayWithChildTopics
{
	NSMutableArray *childTopics = [NSMutableArray array];

	for (AKClassToken *classToken in self.framework.classesGroup.sortedObjects) {
		AKClassTopicUnderFrameworkTopic *classTopic = [[AKClassTopicUnderFrameworkTopic alloc] initWithClassToken:classToken];
		[childTopics addObject:classTopic];
	}

	return childTopics;
}

#pragma mark - <AKNamed> methods

- (NSString *)name
{
	return self.framework.classesGroup.name;
}

@end
