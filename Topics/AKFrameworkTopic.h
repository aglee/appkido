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

@property (strong, readonly) AKDatabase *database;
@property (copy, readonly) NSString *frameworkName;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithFramework:(NSString *)frameworkName database:(AKDatabase *)database NS_DESIGNATED_INITIALIZER;

@end
