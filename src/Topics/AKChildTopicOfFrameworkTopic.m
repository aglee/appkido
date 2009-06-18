/*
 * AKChildTopicOfFrameworkTopic.m
 *
 * Created by Andy Lee on Sat May 14 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKChildTopicOfFrameworkTopic.h"

#import "DIGSLog.h"
#import "AKFramework.h"

@implementation AKChildTopicOfFrameworkTopic

//-------------------------------------------------------------------------
// AKTopic methods
//-------------------------------------------------------------------------

- (NSString *)stringToDisplayInTopicBrowser
{
    DIGSLogError_MissingOverride();
    return nil;
}

- (NSString *)stringToDisplayInDescriptionField
{
    return
        [NSString stringWithFormat:@"%@ %@",
            [_topicFramework frameworkName], [self stringToDisplayInTopicBrowser]];
}

- (NSString *)stringToDisplayInLists
{
    return [self stringToDisplayInDescriptionField];
}

- (NSString *)pathInTopicBrowser
{
    return
        [NSString stringWithFormat:@"%@%@%@%@",
            AKTopicBrowserPathSeparator,
                [_topicFramework frameworkName],
            AKTopicBrowserPathSeparator,
                [self stringToDisplayInTopicBrowser]];
}

@end
