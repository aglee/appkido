/*
 * AKFrameworkTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"

@class AKDatabase;

/*!
 * Represents a framework topic. Subclasses represent different kinds of topic.
 * Provides implementations for several AKTopic abstract methods, but not
 * -childTopics, because that depends on the type of framework.
 *
 * -childTopics should return instances of AKChildTopicOfFrameworkTopic.
 */
@interface AKFrameworkTopic : AKTopic
{
@protected  // [agl] revisit protected ivars
    AKDatabase *_topicDatabase;
    NSString *_topicFrameworkName;
}

#pragma mark -
#pragma mark Factory methods

+ (AKFrameworkTopic *)topicWithFrameworkNamed:(NSString *)frameworkName inDatabase:(AKDatabase *)database;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithFrameworkNamed:(NSString *)frameworkName inDatabase:(AKDatabase *)aDatabase;

@end
