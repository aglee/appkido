/*
 * AKGlobalsTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKGlobalsTopic.h"

#import "AKDatabase.h"
#import "AKSortUtils.h"
#import "AKGroupNode.h"
#import "AKGroupNodeSubtopic.h"
#import "AKDoc.h"

@implementation AKGlobalsTopic

//-------------------------------------------------------------------------
// AKTopic methods
//-------------------------------------------------------------------------

- (NSString *)stringToDisplayInTopicBrowser
{
    return AKGlobalsTopicName;
}

- (int)numberOfSubtopics
{
    return [_database numberOfGlobalsGroupsForFrameworkNamed:[_topicFramework frameworkName]];
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
                [_database globalsGroupsForFrameworkNamed:[_topicFramework frameworkName]]];


    if ((unsigned)subtopicIndex >= [groupNodes count])
    {
        return nil;
    }
    else
    {
        AKGroupNode *groupNode = [groupNodes objectAtIndex:subtopicIndex];

        return [[[AKGroupNodeSubtopic alloc] initWithGroupNode:groupNode] autorelease];
    }
}

- (BOOL)browserCellHasChildren
{
    return NO;
}

@end
