/*
 * AKFunctionsTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFunctionsTopic.h"

#import "AKDatabase.h"
#import "AKSortUtils.h"
#import "AKFunctionsGroupSubtopic.h"

@implementation AKFunctionsTopic

#pragma mark - AKTopic methods

- (NSString *)stringToDisplayInTopicBrowser
{
    return AKFunctionsTopicName;
}

- (NSInteger)numberOfSubtopics
{
    return [self.topicDatabase functionsGroupsForFrameworkNamed:self.topicFrameworkName].count;
}

- (AKSubtopic *)subtopicAtIndex:(NSInteger)subtopicIndex
{
    if (subtopicIndex < 0)
    {
        return nil;
    }

    //TODO: Do we care about the cost of computing this every time?
    NSArray *groupItems = [AKSortUtils arrayBySortingArray:
                [self.topicDatabase functionsGroupsForFrameworkNamed:self.topicFrameworkName]];

    if ((unsigned)subtopicIndex >= groupItems.count)
    {
        return nil;
    }
    else
    {
        AKGroupItem *groupItem = groupItems[subtopicIndex];

        return [[AKFunctionsGroupSubtopic alloc] initWithGroupItem:groupItem];
    }
}

- (BOOL)browserCellHasChildren
{
    return NO;
}

@end
