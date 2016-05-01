/*
 * AKNotificationsSubtopic.m
 *
 * Created by Andy Lee on Wed Sep 25 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKNotificationsSubtopic.h"
#import "AKClassItem.h"
#import "AKNotificationDoc.h"

@implementation AKNotificationsSubtopic

#pragma mark - AKSubtopic methods

- (NSString *)subtopicName
{
    return ([self includesAncestors]
            ? AKAllNotificationsSubtopicName
            : AKNotificationsSubtopicName);
}

#pragma mark - AKMembersSubtopic methods

- (NSArray *)memberItemsForBehavior:(AKBehaviorItem *)behaviorItem
{
    if ([behaviorItem isClassItem])
    {
        return [(AKClassItem *)behaviorItem documentedNotifications];
    }
    else
    {
        return @[];
    }
}

+ (id)memberDocClass
{
    return [AKNotificationDoc class];
}

@end
