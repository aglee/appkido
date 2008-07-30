/*
 * AKNotificationsSubtopic.m
 *
 * Created by Andy Lee on Wed Sep 25 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKNotificationsSubtopic.h"

#import "AKClassNode.h"
#import "AKNotificationDoc.h"

@implementation AKNotificationsSubtopic

//-------------------------------------------------------------------------
// AKSubtopic methods
//-------------------------------------------------------------------------

- (NSString *)subtopicName
{
    return
        [self includesAncestors]
        ? [@"ALL " stringByAppendingString:AKNotificationsSubtopicName]
        : AKNotificationsSubtopicName;
}

- (NSString *)stringToDisplayInSubtopicList
{
    return
        [self includesAncestors]
        ? [@"       " stringByAppendingString:[self subtopicName]]
        : [@"6.  " stringByAppendingString:[self subtopicName]];
}

//-------------------------------------------------------------------------
// AKMembersSubtopic methods
//-------------------------------------------------------------------------

- (NSArray *)memberNodesForBehavior:(AKBehaviorNode *)behaviorNode
{
    if ([behaviorNode isClassNode])
    {
        return [(AKClassNode *)behaviorNode documentedNotifications];
    }
    else
    {
        return [NSArray array];
    }
}

+ (id)memberDocClass
{
    return [AKNotificationDoc class];
}

@end
