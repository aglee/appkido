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
#import "AKGroupItem.h"
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
    return [self.topicDatabase globalsGroupsForFrameworkNamed:self.topicFrameworkName].count;
}

- (AKSubtopic *)subtopicAtIndex:(NSInteger)subtopicIndex
{
    if (subtopicIndex < 0)
    {
        return nil;
    }

    NSArray *groupItems = [AKSortUtils arrayBySortingArray:[self.topicDatabase globalsGroupsForFrameworkNamed:self.topicFrameworkName]];


    if ((unsigned)subtopicIndex >= groupItems.count)
    {
        return nil;
    }
    else
    {
        AKGroupItem *groupItem = groupItems[subtopicIndex];

        return [[AKGlobalsGroupSubtopic alloc] initWithGroupItem:groupItem];
    }
}

- (BOOL)browserCellHasChildren
{
    return NO;
}

@end