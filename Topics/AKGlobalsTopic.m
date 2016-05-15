/*
 * AKGlobalsTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKGlobalsTopic.h"
#import "AKDatabase.h"
#import "AKSortUtils.h"
//#import "AKGlobalsGroupSubtopic.h"
#import "AKGroupItem.h"

@implementation AKGlobalsTopic

#pragma mark - AKTopic methods

- (NSString *)stringToDisplayInTopicBrowser
{
    return AKGlobalsTopicName;
}

- (NSInteger)numberOfSubtopics
{
    return [self.topicDatabase globalsGroupsForFramework:self.topicFrameworkName].count;
}

- (AKSubtopic *)subtopicAtIndex:(NSInteger)subtopicIndex
{
    if (subtopicIndex < 0)
    {
        return nil;
    }

    NSArray *groupItems = [AKSortUtils arrayBySortingArray:[self.topicDatabase globalsGroupsForFramework:self.topicFrameworkName]];


    if ((unsigned)subtopicIndex >= groupItems.count)
    {
        return nil;
    }
    else
    {
//        AKGroupItem *groupItem = groupItems[subtopicIndex];
//
//        return [[AKGlobalsGroupSubtopic alloc] initWithGroupItem:groupItem];
        return nil;  //TODO: Clean this up.
    }
}

- (BOOL)browserCellHasChildren
{
    return NO;
}

@end
