/*
 * AKBehaviorTopic.h
 *
 * Created by Andy Lee on Mon May 26 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"

@interface AKBehaviorTopic : AKTopic

/*! Subclasses must override. */
@property (copy, readonly) NSString *behaviorName;

#pragma mark - Subtopics

/*! Subclasses must override. For internal use only. */
- (NSArray *)arrayWithSubtopics;

@end
