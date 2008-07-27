/*
 * AKBehaviorTopic.m
 *
 * Created by Andy Lee on Mon May 26 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorTopic.h"

#import <DIGSLog.h>

//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKBehaviorTopic (Private)
- (NSArray *)_subtopics;
@end


@implementation AKBehaviorTopic

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (void)dealloc
{
    [_subtopics release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSString *)behaviorName
{
    DIGSLogMissingOverride();
    return nil;
}

//-------------------------------------------------------------------------
// AKTopic methods
//-------------------------------------------------------------------------

- (NSDictionary *)asPrefDictionary
{
    NSMutableDictionary *prefDict = [NSMutableDictionary dictionary];

    [prefDict
        setObject:[self className]
        forKey:AKTopicClassNamePrefKey];

    [prefDict
        setObject:[self behaviorName]
        forKey:AKBehaviorNamePrefKey];

    return prefDict;
}

- (int)numberOfSubtopics
{
    return [[self _subtopics] count];
}

- (AKSubtopic *)subtopicAtIndex:(int)subtopicIndex
{
    if (subtopicIndex < 0)
    {
        return nil;
    }

    return [[self _subtopics] objectAtIndex:subtopicIndex];
}

//-------------------------------------------------------------------------
// Initialization support
//-------------------------------------------------------------------------

- (NSArray *)createSubtopicsArray
{
    DIGSLogMissingOverride();
    return nil;
}

//-------------------------------------------------------------------------
// AKSortable methods
//-------------------------------------------------------------------------

- (NSString *)sortName
{
    return [self behaviorName];
}

@end


//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation AKBehaviorTopic (Private)

- (NSArray *)_subtopics
{
    if (!_subtopics)
    {
        _subtopics = [[self createSubtopicsArray] retain];
    }

    return _subtopics;
}

@end


