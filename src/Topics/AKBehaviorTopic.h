/*
 * AKBehaviorTopic.h
 *
 * Created by Andy Lee on Mon May 26 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"

// [agl] same for any class/protocol regardless of framework
@interface AKBehaviorTopic : AKTopic
{
    // Elements are instances of AKSubtopic classes.
    NSArray *_subtopics;
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

// subclasses must implement
- (NSString *)behaviorName;

//-------------------------------------------------------------------------
// Initialization support
//-------------------------------------------------------------------------

// subclasses must implement; for internal use only
- (NSArray *)createSubtopicsArray;

@end


