/*
 * AKFrameworkTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"

@class AKDatabase;

// represents one framework; subclasses represent different kinds of fw
// provides implementations for several AKTopic abstract methods, but not
// -childTopics, because that depends on the type of fw
//
// -childTopics should return instances of
// AKChildTopicOfFrameworkTopic
@interface AKFrameworkTopic : AKTopic
{
@protected
    NSString *_topicFramework;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (AKFrameworkTopic *)topicWithFramework:(NSString *)fwName
    inDatabase:(AKDatabase *)database;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*! Designated initializer. */
- (id)initWithFramework:(NSString *)fwName
    inDatabase:(AKDatabase *)database;

@end
