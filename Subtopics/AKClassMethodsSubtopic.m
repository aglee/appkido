/*
 * AKClassMethodsSubtopic.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKClassMethodsSubtopic.h"

#import "AKBehaviorToken.h"
#import "AKClassMethodDoc.h"

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

- (NSArray *)memberItemsForBehavior:(AKBehaviorToken *)behaviorToken
{
    return [behaviorToken classMethodItems];
}

+ (id)memberDocClass
{
    return [AKClassMethodDoc class];
}

@end
