/*
 * AKGlobalsTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKGlobalsTopic.h"
#import "AKDatabase.h"
#import "AKGroupItem.h"
#import "AKSortUtils.h"

@implementation AKGlobalsTopic

#pragma mark - AKTopic methods

- (AKSubtopic *)subtopicAtIndex:(NSInteger)subtopicIndex
{
	if (subtopicIndex < 0) {
		return nil;
	}

	NSArray *groupItems = [AKSortUtils arrayBySortingArray:[self.database globalsGroupsForFramework:self.frameworkName]];


	if ((NSUInteger)subtopicIndex >= groupItems.count) {
		return nil;
	} else {
//		AKGroupItem *groupItem = groupItems[subtopicIndex];
//
//		return [[AKGlobalsGroupSubtopic alloc] initWithGroupItem:groupItem];
		return nil;  //TODO: Clean this up.
	}
}

#pragma mark - <AKNamed> methods

- (NSString *)name
{
	return AKGlobalsTopicName;
}

@end
