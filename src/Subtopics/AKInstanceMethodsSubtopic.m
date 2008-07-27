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

//-------------------------------------------------------------------------
// AKSubtopic methods
//-------------------------------------------------------------------------

- (NSString *)subtopicName
{
    return
        [self includesAncestors]
        ? [@"ALL " stringByAppendingString:AKInstanceMethodsSubtopicName]
        : AKInstanceMethodsSubtopicName;
}

- (NSString *)stringToDisplayInSubtopicList
{
    return
        [self includesAncestors]
        ? [@"       " stringByAppendingString:[self subtopicName]]
        : [@"4.  " stringByAppendingString:[self subtopicName]];
}

//-------------------------------------------------------------------------
// AKMethodsSubtopic methods
//-------------------------------------------------------------------------

- (NSArray *)methodNodesForBehavior:(AKBehaviorNode *)behaviorNode
{
    return [behaviorNode documentedInstanceMethods];
}

+ (id)methodDocClass
{
    return [AKInstanceMethodDoc class];
}

@end
