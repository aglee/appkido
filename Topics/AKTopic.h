/*
 * AKTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSortable.h"
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
 * IMPORTANT TERMINOLOGY: when a topic is selected in the topic browser, the
 * selected AKTopic provides **child topics** for populating the next column of
 * the browser, and **subtopics** for populating the subtopics list. For
 * example, when a class is selected in the topic browser, the **child topics**
 * are the class's subclasses and the **subtopics** include "Class Methods",
 * "Instance Methods", etc.
 */
@interface AKTopic : NSObject <AKPrefDictionary, AKSortable>

@property (readonly, strong) AKClassToken *parentClassOfTopic;  //TODO: KLUDGE

/*! May be nil. */
@property (readonly, strong) AKToken *topicToken;

#pragma mark - Names for various display contexts

/*! Subclasses must override. */
@property (copy, readonly) NSString *name;
@property (copy, readonly) NSString *stringToDisplayInDescriptionField;
@property (copy, readonly) NSString *displayName;

#pragma mark - Populating the topic browser

/*! Subclasses must override. */
@property (copy, readonly) NSString *pathInTopicBrowser;

/*! Subclasses may override. Defaults to YES. */
@property (assign, readonly) BOOL browserCellShouldBeEnabled;

/*! Subclasses may override. Defaults to YES. */
@property (assign, readonly) BOOL browserCellHasChildren;

/*!
 * Subclasses must override if they can possibly have children. Returns array of
 * AKTopics. Note the distinction between child topics and subtopics.
 */
@property (copy, readonly) NSArray *childTopics;

#pragma mark - Subtopics

/*! Subclasses must override. */
@property (assign, readonly) NSInteger numberOfSubtopics;

/*! Subclasses must override. */
- (AKSubtopic *)subtopicAtIndex:(NSInteger)subtopicIndex;

/*! Returns -1 if none found. */
- (NSInteger)indexOfSubtopicWithName:(NSString *)subtopicName;

- (AKSubtopic *)subtopicWithName:(NSString *)subtopicName;

/*! Convenience method. */
- (AKSubtopic *)subtopicWithName:(NSString *)name
					docListItems:(NSArray *)docListItems
							sort:(BOOL)sort;

@end
