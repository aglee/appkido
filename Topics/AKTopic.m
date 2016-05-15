/*
 * AKTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"
#import "DIGSLog.h"
#import "AKClassToken.h"
#import "AKSubtopic.h"

@implementation AKTopic

#pragma mark - Getters and setters

- (AKClassToken *)parentClassOfTopic
{
	return nil;
}

- (AKToken *)topicToken
{
	return nil;
}

#pragma mark - Names for various display contexts

- (NSString *)name
{
	DIGSLogError_MissingOverride();
	return @"??";
}

- (NSString *)stringToDisplayInDescriptionField
{
	return @"...";
}

- (NSString *)displayName
{
	return [self name];
}

#pragma mark - Populating the topic browser

- (NSString *)pathInTopicBrowser
{
	DIGSLogError_MissingOverride();
	return nil;
}

- (BOOL)browserCellShouldBeEnabled
{
	return YES;
}

- (BOOL)browserCellHasChildren
{
	return YES;
}

- (NSArray *)childTopics
{
	return nil;
}

#pragma mark - Subtopics

- (NSInteger)numberOfSubtopics
{
	return 0;
}

- (AKSubtopic *)subtopicAtIndex:(NSInteger)subtopicIndex
{
	DIGSLogError_MissingOverride();
	return nil;
}

- (NSInteger)indexOfSubtopicWithName:(NSString *)subtopicName
{
	if (subtopicName == nil) {
		return -1;
	}

	NSInteger numSubtopics = [self numberOfSubtopics];
	NSInteger i;

	for (i = 0; i < numSubtopics; i++) {
		AKSubtopic *subtopic = [self subtopicAtIndex:i];
		if ([[subtopic name] isEqualToString:subtopicName]) {
			return i;
		}
	}

	// If we got this far, the search failed.
	return -1;
}

- (AKSubtopic *)subtopicWithName:(NSString *)subtopicName
{
	NSInteger subtopicIndex = ((subtopicName == nil)
							   ? -1
							   : [self indexOfSubtopicWithName:subtopicName]);
	return ((subtopicIndex < 0)
			? nil
			: [self subtopicAtIndex:subtopicIndex]);
}

- (AKSubtopic *)subtopicWithName:(NSString *)name
					docListItems:(NSArray *)docListItems
							sort:(BOOL)sort
{
	if (sort) {
		docListItems = [AKSortUtils arrayBySortingArray:docListItems];
	}
	return [[AKSubtopic alloc] initWithName:name docListItems:docListItems];
}

#pragma mark - AKPrefDictionary methods

+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict
{
	if (prefDict == nil) {
		return nil;
	}

	NSString *topicClassName = prefDict[AKTopicClassNamePrefKey];

	if (topicClassName == nil) {
		DIGSLogWarning(@"missing name of topic class");
		return nil;
	}

	Class topicClass = NSClassFromString(topicClassName);
	if (topicClass == nil) {
		DIGSLogInfo(@"couldn't find a class called %@", topicClassName);
		return nil;
	} else {
		Class cl = topicClass;

		while ((cl = [cl superclass]) != nil) {
			if (cl == [AKTopic class]) {
				break;
			}
		}

		if (cl == nil) {
			DIGSLogWarning(@"%@ is not a proper descendant class of AKTopic", topicClassName);
			return nil;
		}
	}

	return (AKTopic *)[topicClass fromPrefDictionary:prefDict];
}

- (NSDictionary *)asPrefDictionary
{
	DIGSLogError_MissingOverride();
	return nil;
}

#pragma mark - <AKSortable> methods

- (NSString *)sortName
{
	return [self displayName];
}

#pragma mark - NSObject methods

// Compare topics by comparing their browser paths.
- (BOOL)isEqual:(id)anObject
{
	if (![anObject isKindOfClass:[AKTopic class]]) {
		return NO;
	}
	NSString *otherPath = ((AKTopic *)anObject).pathInTopicBrowser;
	return [otherPath isEqualToString:self.pathInTopicBrowser];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: browserPath=%@>", self.className, self.pathInTopicBrowser];
}

@end
