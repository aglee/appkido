/*
 * AKChildTopicOfFrameworkTopic.m
 *
 * Created by Andy Lee on Sat May 14 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKChildTopicOfFrameworkTopic.h"

#import "DIGSLog.h"

@implementation AKChildTopicOfFrameworkTopic

#pragma mark - AKTopic methods

- (NSString *)name
{
    DIGSLogError_MissingOverride();
    return nil;
}

- (NSString *)stringToDisplayInDescriptionField
{
    return [NSString stringWithFormat:@"%@ %@",
            self.topicFrameworkName, [self name]];
}

- (NSString *)displayName
{
    return [self stringToDisplayInDescriptionField];
}

- (NSString *)pathInTopicBrowser
{
    return [NSString stringWithFormat:@"%@%@%@%@",
            AKTopicBrowserPathSeparator,
            self.topicFrameworkName,
            AKTopicBrowserPathSeparator,
            [self name]];
}

@end
