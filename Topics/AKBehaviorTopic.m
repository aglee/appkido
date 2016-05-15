/*
 * AKBehaviorTopic.m
 *
 * Created by Andy Lee on Mon May 26 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorTopic.h"

#import "DIGSLog.h"

@implementation AKBehaviorTopic

#pragma mark - Getters and setters

- (NSString *)behaviorName
{
    DIGSLogError_MissingOverride();
    return nil;
}

#pragma mark - AKTopic methods

- (NSDictionary *)asPrefDictionary
{
    NSMutableDictionary *prefDict = [NSMutableDictionary dictionary];

    prefDict[AKTopicClassNamePrefKey] = self.className;
    prefDict[AKBehaviorNamePrefKey] = [self behaviorName];

    return prefDict;
}

- (NSInteger)numberOfSubtopics
{
    return [self _subtopics].count;
}

- (AKSubtopic *)subtopicAtIndex:(NSInteger)subtopicIndex
{
    if (subtopicIndex < 0)
    {
        return nil;
    }

    return [self _subtopics][subtopicIndex];
}

#pragma mark - Subtopics

- (NSArray *)arrayWithSubtopics
{
    DIGSLogError_MissingOverride();
    return nil;
}

#pragma mark - AKSortable methods

- (NSString *)sortName
{
    return [self behaviorName];
}

#pragma mark - Private methods

- (NSArray *)_subtopics
{
    if (!_subtopics)
    {
        _subtopics = [self arrayWithSubtopics];
    }
    return _subtopics;
}

@end
