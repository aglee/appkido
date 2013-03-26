/*
 * AKDelegateMethodsSubtopic.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDelegateMethodsSubtopic.h"

#import "AKClassNode.h"
#import "AKDelegateMethodDoc.h"

@implementation AKDelegateMethodsSubtopic

#pragma mark -
#pragma mark AKSubtopic methods

- (NSString *)subtopicName
{
    return ([self includesAncestors]
            ? AKAllDelegateMethodsSubtopicName
            : AKDelegateMethodsSubtopicName);
}

- (NSString *)stringToDisplayInSubtopicList
{
    return ([self includesAncestors]
            ? [@"       " stringByAppendingString:[self subtopicName]]
            : [@"5.  " stringByAppendingString:[self subtopicName]]);
}

#pragma mark -
#pragma mark AKMembersSubtopic methods

- (NSArray *)memberNodesForBehavior:(AKBehaviorNode *)behaviorNode
{
    if ([behaviorNode isClassNode])
    {
        return [(AKClassNode *)behaviorNode documentedDelegateMethods];
    }
    else
    {
        return @[];
    }
}

+ (id)memberDocClass
{
    return [AKDelegateMethodDoc class];
}

@end
