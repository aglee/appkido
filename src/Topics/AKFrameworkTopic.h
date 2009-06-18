/*
 * AKFrameworkTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"

@class AKDatabase;
@class AKFramework;

// represents one framework; subclasses represent different kinds of fw
// provides implementations for several AKTopic abstract methods, but not
// -childTopics, because that depends on the type of fw
//
// -childTopics should return instances of
// AKChildTopicOfFrameworkTopic
@interface AKFrameworkTopic : AKTopic
{
@protected
    AKFramework *_topicFramework;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (AKFrameworkTopic *)topicWithFrameworkNamed:(NSString *)frameworkName inDatabase:(AKDatabase *)database;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*! Designated initializer. */
- (id)initWithFrameworkNamed:(NSString *)frameworkName inDatabase:(AKDatabase *)aDatabase;

@end
