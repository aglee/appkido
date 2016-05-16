/*
 * AKLabelTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKLabelTopic.h"
#import "DIGSLog.h"

@implementation AKLabelTopic

#pragma mark - Init/awake/dealloc

- (instancetype)initWithLabel:(NSString *)label
{
	self = [super init];
	if (self) {
		_label = label;
	}
	return self;
}

#pragma mark - AKTopic methods

- (NSString *)pathInTopicBrowser
{
	return [NSString stringWithFormat:@"%@%@", AKTopicBrowserPathSeparator, self.label];
}

- (BOOL)browserCellShouldBeEnabled
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
		return [[self alloc] initWithLabel:labelString];
	}
}

- (NSDictionary *)asPrefDictionary
{
	return @{ AKTopicClassNamePrefKey: self.className,
			  AKLabelStringPrefKey: self.label };
}

#pragma mark - <AKNamed> methods

- (NSString *)name
{
	return self.label;
}

@end
