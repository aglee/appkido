/*
 * AKBehaviorTopic.m
 *
 * Created by Andy Lee on Mon May 26 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorTopic.h"
#import "DIGSLog.h"

@interface AKBehaviorTopic ()
@property (copy, readonly) NSArray *subtopics;  // Contains AKSubtopics.
@end

@implementation AKBehaviorTopic

@dynamic behaviorName;
@synthesize subtopics = _subtopics;

#pragma mark - Getters and setters

- (NSArray *)subtopics
{
	// Lazy loading.  We do this because there are common cases where we'll
	// have AKBehaviorTopic instances and never need to ask for their subtopics
	// (for example in a list of search results which the user may never
	// select).
	if (!_subtopics) {
		_subtopics = [self arrayWithSubtopics];
	}
	return _subtopics;
}

#pragma mark - AKTopic methods

- (NSDictionary *)asPrefDictionary
{
	return @{ AKTopicClassNamePrefKey : self.className,
			  AKBehaviorNamePrefKey : self.behaviorName };
}

- (NSInteger)numberOfSubtopics
{
	return self.subtopics.count;
}

- (id<AKSubtopicListItem>)subtopicAtIndex:(NSInteger)subtopicIndex
{
	return (subtopicIndex < 0
			? nil
			: self.subtopics[subtopicIndex]);
}

#pragma mark - Subtopics

- (NSArray *)arrayWithSubtopics
{
	DIGSLogError_MissingOverride();
	return nil;
}

#pragma mark - AKSortable methods

- (NSString *)sortName
{
	return self.behaviorName;
}

@end
