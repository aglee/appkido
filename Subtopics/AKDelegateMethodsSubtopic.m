/*
 * AKDelegateMethodsSubtopic.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDelegateMethodsSubtopic.h"
#import "AKClassItem.h"
#import "AKDelegateMethodDoc.h"

@implementation AKDelegateMethodsSubtopic

#pragma mark - AKSubtopic methods

- (NSString *)subtopicName
{
    return ([self includesAncestors]
            ? AKAllDelegateMethodsSubtopicName
            : AKDelegateMethodsSubtopicName);
}

#pragma mark - AKMembersSubtopic methods

- (NSArray *)memberItemsForBehavior:(AKBehaviorToken *)behaviorToken
{
    if ([behaviorToken isClassItem])
    {
        return [(AKClassItem *)behaviorToken documentedDelegateMethods];
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
