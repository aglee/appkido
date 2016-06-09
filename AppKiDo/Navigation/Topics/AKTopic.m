/*
 * AKTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"
#import "AKClassToken.h"
#import "AKSubtopic.h"
#import "DIGSLog.h"
#import "NSArray+AppKiDo.h"

@implementation AKTopic

@synthesize childTopics = _childTopics;
@synthesize subtopics = _subtopics;

#pragma mark - Getters and setters

- (AKToken *)topicToken
{
	return nil;
}

- (AKClassToken *)superclassTokenForTopicToken
{
	return nil;
}

- (NSString *)pathInTopicBrowser
{
	DIGSLogError_MissingOverride();
	return nil;
}

- (NSString *)stringToDisplayInDescriptionField
{
	return @"...";
}

- (BOOL)browserCellShouldBeEnabled
{
	return YES;
}

- (NSArray *)childTopics
{
	// Lazy loading.  //TODO: Is this necessary?  Descendant topics will never get dealloc'ed unless root topics are dealloc'ed.
	if (_childTopics == nil) {
		_childTopics = [self _arrayWithChildTopics];
	}
	return _childTopics;
}

- (NSArray *)subtopics
{
	// Lazy loading.
	if (_subtopics == nil) {
		_subtopics = [self _arrayWithSubtopics];
	}
	return _subtopics;
}

#pragma mark - Accessing child topics

- (AKTopic *)childTopicWithName:(NSString *)childTopicName
{
	for (AKTopic *child in self.childTopics) {
		if ([child.name isEqualToString:childTopicName]) {
			return child;
		}
	}
	return nil;
}

#pragma mark - Accessing subtopics

- (NSInteger)indexOfSubtopicWithName:(NSString *)subtopicName
{
	if (subtopicName == nil) {
		return -1;
	}

	for (NSUInteger i = 0; i < self.subtopics.count; i++) {
		if ([[self subtopicAtIndex:i].name isEqualToString:subtopicName]) {
			return i;
		}
	}

	// If we got this far, the search failed.
	return -1;
}

- (AKSubtopic *)subtopicAtIndex:(NSInteger)subtopicIndex
{
	return self.subtopics[subtopicIndex];
}

- (AKSubtopic *)subtopicWithName:(NSString *)subtopicName
{
	NSInteger subtopicIndex = ((subtopicName == nil)
							   ? -1
							   : [self indexOfSubtopicWithName:subtopicName]);
	return (subtopicIndex < 0
			? nil
			: [self subtopicAtIndex:subtopicIndex]);
}



#pragma mark - <AKNamed> methods

- (NSString *)name
{
	DIGSLogError_MissingOverride();
	return @"??";
}

- (NSString *)sortName
{
	return self.name;
}

- (NSString *)displayName
{
	return self.name;
}

#pragma mark - <AKPrefDictionary> methods

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

#pragma mark - For internal use

AKSubtopic *AKCreateSubtopic(NSString *subtopicName, NSArray *docListItems, BOOL sort)
{
	if (sort) {
		docListItems = [docListItems ak_sortedBySortName];
	}
	return [[AKSubtopic alloc] initWithName:subtopicName docListItems:docListItems];
}

- (NSArray *)_arrayWithChildTopics
{
	return @[];
}

- (NSArray *)_arrayWithSubtopics
{
	return @[];
}

@end
