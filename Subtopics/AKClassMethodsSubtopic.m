/*
 * AKClassMethodsSubtopic.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKClassMethodsSubtopic.h"
#import "AKBehaviorToken.h"

@implementation AKClassMethodsSubtopic

#pragma mark - AKSubtopic methods

- (NSString *)subtopicName
{
    return ([self includesAncestors]
            ? AKAllClassMethodsSubtopicName
            : AKClassMethodsSubtopicName);
}

- (NSString *)stringToDisplayInSubtopicList
{
    return ([self includesAncestors]
            ? [@"       " stringByAppendingString:[self subtopicName]]
            : [self subtopicName]);
}

#pragma mark - AKMembersSubtopic methods

- (NSArray *)memberTokensForBehavior:(AKBehaviorToken *)behaviorToken
{
    return [behaviorToken classMethodTokens];
}

@end
