//
//  AKClassTopicUnderFrameworkTopic.m
//  AppKiDo
//
//  Created by Andy Lee on 6/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKClassTopicUnderFrameworkTopic.h"
#import "AKClassToken.h"
#import "AKTopicConstants.h"

@implementation AKClassTopicUnderFrameworkTopic

#pragma mark - AKTopic methods

- (NSString *)pathInTopicBrowser
{
	return [NSString stringWithFormat:@"%@%@%@%@%@%@",
			AKTopicBrowserPathSeparator, self.classToken.frameworkName,
			AKTopicBrowserPathSeparator, AKClassesTopicName,
			AKTopicBrowserPathSeparator, self.classToken.name];
}

- (NSArray *)_arrayWithChildTopics
{
	return nil;
}

@end
