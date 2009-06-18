/*
 * AKFunctionsTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFunctionsTopic.h"

#import "AKDatabase.h"
#import "AKFramework.h"
#import "AKSortUtils.h"
#import "AKFunctionsSubtopic.h"

@implementation AKFunctionsTopic

//-------------------------------------------------------------------------
// AKTopic methods
//-------------------------------------------------------------------------

- (NSString *)stringToDisplayInTopicBrowser
{
    return AKFunctionsTopicName;
}

- (int)numberOfSubtopics
{
    return
        [[_topicFramework fwDatabase]
            numberOfFunctionsGroupsForFrameworkNamed:[_topicFramework frameworkName]];
}

- (AKSubtopic *)subtopicAtIndex:(int)subtopicIndex
{
    if (subtopicIndex < 0)
    {
        return nil;
    }

    NSArray *groupNodes =
        [AKSortUtils
            arrayBySortingArray:
                [[_topicFramework fwDatabase] functionsGroupsForFrameworkNamed:[_topicFramework frameworkName]]];

    if ((unsigned)subtopicIndex >= [groupNodes count])
    {
        return nil;
    }
    else
    {
        AKGroupNode *groupNode = [groupNodes objectAtIndex:subtopicIndex];

        return [[[AKFunctionsSubtopic alloc] initWithGroupNode:groupNode] autorelease];
    }
}

- (BOOL)browserCellHasChildren
{
    return NO;
}

@end
