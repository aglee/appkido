/*
 * AKDelegateMethodsSubtopic.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDelegateMethodsSubtopic.h"
#import "AKClassToken.h"
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

- (NSArray *)memberTokensForBehavior:(AKBehaviorToken *)behaviorToken
{
    if ([behaviorToken isClassToken])
    {
        return [(AKClassToken *)behaviorToken documentedDelegateMethods];
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
