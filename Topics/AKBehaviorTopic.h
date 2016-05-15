/*
 * AKBehaviorTopic.h
 *
 * Created by Andy Lee on Mon May 26 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"

@interface AKBehaviorTopic : AKTopic
{
@private
    // Elements are instances of AKSubtopic classes. The array is lazily
    // instantiated and populated because there are common cases where we'll
    // have AKBehaviorTopic instances and never need to ask for their subtopics
    // (for example in a list of search results which the user may never
    // select).
    NSArray *_subtopics;
}

#pragma mark - Getters and setters

/*! Subclasses must override. */
@property (readonly, copy) NSString *behaviorName;

#pragma mark - Subtopics

/*! Subclasses must override. For internal use only. */
- (NSArray *)arrayWithSubtopics;

@end
