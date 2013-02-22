/*
 * AKFunctionsTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFunctionsTopic.h"

#import "AKDatabase.h"
#import "AKSortUtils.h"
#import "AKFunctionsSubtopic.h"

@implementation AKFunctionsTopic

#pragma mark -
#pragma mark AKTopic methods

- (NSString *)stringToDisplayInTopicBrowser
{
    return AKFunctionsTopicName;
}

- (NSInteger)numberOfSubtopics
{
    return [_topicDatabase numberOfFunctionsGroupsForFrameworkNamed:_topicFrameworkName];
}

- (AKSubtopic *)subtopicAtIndex:(NSInteger)subtopicIndex
{
    if (subtopicIndex < 0)
    {
        return nil;
    }

    // [agl] Do we care about the cost of computing this every time?
    NSArray *groupNodes = [AKSortUtils arrayBySortingArray:
                [_topicDatabase functionsGroupsForFrameworkNamed:_topicFrameworkName]];

    if ((unsigned)subtopicIndex >= [groupNodes count])
    {
        return nil;
    }
    else
    {
        AKGroupNode *groupNode = [groupNodes objectAtIndex:subtopicIndex];

        return [[AKFunctionsSubtopic alloc] initWithGroupNode:groupNode];
    }
}

- (BOOL)browserCellHasChildren
{
    return NO;
}


@end
