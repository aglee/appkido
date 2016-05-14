/*
 * AKLabelTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKLabelTopic.h"
#import "DIGSLog.h"

@implementation AKLabelTopic

NSString *AKClassesLabelTopicName = @":: classes ::";
NSString *AKOtherTopicsLabelTopicName = @":: other topics ::";

#pragma mark - Factory methods

+ (AKLabelTopic *)topicWithLabel:(NSString *)label
{
	AKLabelTopic *topic = [[self alloc] init];
	topic.label = label;
	return topic;
}

#pragma mark - AKTopic methods

- (NSString *)stringToDisplayInTopicBrowser
{
	return self.label;
}

- (NSString *)pathInTopicBrowser
{
	return [NSString stringWithFormat:@"%@%@", AKTopicBrowserPathSeparator, self.label];
}

- (BOOL)browserCellShouldBeEnabled
{
	return NO;
}

- (BOOL)browserCellHasChildren
{
	return NO;
}

#pragma mark - AKPrefDictionary methods

+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict
{
	if (prefDict == nil) {
		return nil;
	}

	NSString *labelString = prefDict[AKLabelStringPrefKey];
	if (labelString == nil) {
		DIGSLogWarning(@"malformed pref dictionary for class %@", [self className]);
		return nil;
	} else {
		return [self topicWithLabel:labelString];
	}
}

- (NSDictionary *)asPrefDictionary
{
	NSMutableDictionary *prefDict = [NSMutableDictionary dictionary];
	prefDict[AKTopicClassNamePrefKey] = self.className;
	prefDict[AKLabelStringPrefKey] = self.label;
	return prefDict;
}

#pragma mark - AKSortable methods

- (NSString *)sortName
{
	return self.label;
}

@end
