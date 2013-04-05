/*
 * AKGlobalsTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKGlobalsTopic.h"

#import "AKDatabase.h"
#import "AKSortUtils.h"
#import "AKGlobalsGroupSubtopic.h"
#import "AKGroupNode.h"
#import "AKDoc.h"

@implementation AKGlobalsTopic

#pragma mark -
#pragma mark AKTopic methods

- (NSString *)stringToDisplayInTopicBrowser
{
    return AKGlobalsTopicName;
}

- (NSInteger)numberOfSubtopics
{
    return [[[self topicDatabase] globalsGroupsForFrameworkNamed:[self topicFrameworkName]] count];
}

- (AKSubtopic *)subtopicAtIndex:(NSInteger)subtopicIndex
{
    if (subtopicIndex < 0)
    {
        return nil;
    }

    NSArray *groupNodes = [AKSortUtils arrayBySortingArray:[[self topicDatabase] globalsGroupsForFrameworkNamed:[self topicFrameworkName]]];


    if ((unsigned)subtopicIndex >= [groupNodes count])
    {
        return nil;
    }
    else
    {
        AKGroupNode *groupNode = [groupNodes objectAtIndex:subtopicIndex];

        return [[[AKGlobalsGroupSubtopic alloc] initWithGroupNode:groupNode] autorelease];
    }
}

- (BOOL)browserCellHasChildren
{
    return NO;
}

@end
