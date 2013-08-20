/*
 * AKClassMethodsSubtopic.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKClassMethodsSubtopic.h"

#import "AKBehaviorNode.h"
#import "AKClassMethodDoc.h"

@implementation AKClassMethodsSubtopic

#pragma mark -
#pragma mark AKSubtopic methods

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

#pragma mark -
#pragma mark AKMembersSubtopic methods

- (NSArray *)memberNodesForBehavior:(AKBehaviorNode *)behaviorNode
{
    return [behaviorNode documentedClassMethods];
}

+ (id)memberDocClass
{
    return [AKClassMethodDoc class];
}

@end
