/*
 * AKFrameworkTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"

@class AKDatabase;

/*!
 * Abstract class that represents an aspect of a framework other than its
 * classes -- for example, its functions or its formal protocols. Provides
 * implementations for several AKTopic abstract methods, but not childTopics,
 * because that depends on the type of framework. Subclasses must override
 * childTopics to return instances of AKChildTopicOfFrameworkTopic.
 */
@interface AKFrameworkTopic : AKTopic
{
@private
    AKDatabase *_topicDatabase;
    NSString *_topicFrameworkName;
}

@property (nonatomic, readonly, strong) AKDatabase *topicDatabase;
@property (nonatomic, readonly, copy) NSString *topicFrameworkName;

#pragma mark - Factory methods

+ (AKFrameworkTopic *)topicWithFramework:(NSString *)frameworkName inDatabase:(AKDatabase *)database;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithFramework:(NSString *)frameworkName inDatabase:(AKDatabase *)aDatabase NS_DESIGNATED_INITIALIZER;

@end
