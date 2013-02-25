/*
 * AKBehaviorTopic.h
 *
 * Created by Andy Lee on Mon May 26 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"

/*!
 * [agl] same for any class/protocol regardless of framework
 */
@interface AKBehaviorTopic : AKTopic
{
@private
    // Elements are instances of AKSubtopic classes.
    NSArray *_subtopics;
}

#pragma mark -
#pragma mark Getters and setters

/*! Subclasses must override. */
- (NSString *)behaviorName;

#pragma mark -
#pragma mark Initialization support

/*! Subclasses must override. For internal use only. */
- (NSArray *)createSubtopicsArray;

@end
