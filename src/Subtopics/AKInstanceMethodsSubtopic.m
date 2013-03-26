/*
 * AKInstanceMethodsSubtopic.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKInstanceMethodsSubtopic.h"

#import "AKBehaviorNode.h"
#import "AKInstanceMethodDoc.h"

@implementation AKInstanceMethodsSubtopic

#pragma mark -
#pragma mark AKSubtopic methods

- (NSString *)subtopicName
{
    return ([self includesAncestors]
            ? AKAllInstanceMethodsSubtopicName
            : AKInstanceMethodsSubtopicName);
}

- (NSString *)stringToDisplayInSubtopicList
{
    return ([self includesAncestors]
            ? [@"       " stringByAppendingString:[self subtopicName]]
            : [@"4.  " stringByAppendingString:[self subtopicName]]);
}

#pragma mark -
#pragma mark AKMembersSubtopic methods

- (NSArray *)memberNodesForBehavior:(AKBehaviorNode *)behaviorNode
{
    return [behaviorNode documentedInstanceMethods];
}

+ (id)memberDocClass
{
    return [AKInstanceMethodDoc class];
}

@end
