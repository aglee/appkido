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

//-------------------------------------------------------------------------
// AKSubtopic methods
//-------------------------------------------------------------------------

- (NSString *)subtopicName
{
    return
        [self includesAncestors]
        ? [@"ALL " stringByAppendingString:AKClassMethodsSubtopicName]
        : AKClassMethodsSubtopicName;
}

- (NSString *)stringToDisplayInSubtopicList
{
    return
        [self includesAncestors]
        ? [@"       " stringByAppendingString:[self subtopicName]]
        : [@"3.  " stringByAppendingString:[self subtopicName]];
}

//-------------------------------------------------------------------------
// AKMembersSubtopic methods
//-------------------------------------------------------------------------

- (NSArray *)memberNodesForBehavior:(AKBehaviorNode *)behaviorNode
{
    return [behaviorNode documentedClassMethods];
}

+ (id)memberDocClass
{
    return [AKClassMethodDoc class];
}

@end
