/*
 * AKTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "AKNamed.h"
#import "AKPrefDictionary.h"
#import "AKPrefUtils.h"
#import "AKTopicConstants.h"

@class AKClassToken;
@class AKToken;
@class AKSubtopic;

/*!
 * Abstract class that represents a "topic". Used as the representedObject of
 * cells in the topic browser.
 *
 * Concrete subclasses must implement _arrayWithChildTopics and
 * _arrayWithSubtopics.
 *
 * IMPORTANT TERMINOLOGY: when a topic is selected in the topic browser, the
 * selected AKTopic provides **child topics** for populating the next column of
 * the browser, and **subtopics** for populating the subtopics list. For
 * example, when a class is selected in the topic browser, the **child topics**
 * are the class's subclasses and the **subtopics** include "Class Methods",
 * "Instance Methods", etc.
 */
@interface AKTopic : NSObject <AKNamed, AKPrefDictionary>

@property (strong, readonly) AKToken *topicToken;  //TODO: KLUDGE
@property (strong, readonly) AKClassToken *parentClassOfTopic;  //TODO: KLUDGE

@property (copy, readonly) NSString *pathInTopicBrowser;
@property (assign, readonly) BOOL browserCellShouldBeEnabled;

@property (copy, readonly) NSString *stringToDisplayInDescriptionField;

@property (copy, readonly) NSArray *childTopics;
@property (copy, readonly) NSArray *subtopics;

#pragma mark - Accessing child topics

- (AKTopic *)childTopicWithName:(NSString *)childTopicName;

#pragma mark - Accessing subtopics

/*! Returns -1 if none found. */
- (NSInteger)indexOfSubtopicWithName:(NSString *)subtopicName;
- (AKSubtopic *)subtopicAtIndex:(NSInteger)subtopicIndex;
- (AKSubtopic *)subtopicWithName:(NSString *)subtopicName;

#pragma mark - For internal use

extern AKSubtopic *AKCreateSubtopic(NSString *subtopicName, NSArray *docListItems, BOOL sort);

/*! Subclasses must override.  Used for lazy loading _childTopics. */
- (NSArray *)_arrayWithChildTopics;

/*! Subclasses must override.  Used for lazy loading _subtopics. */
- (NSArray *)_arrayWithSubtopics;

@end
