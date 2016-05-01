/*
 * AKTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSortable.h"
#import "AKPrefDictionary.h"
#import "AKPrefUtils.h"

@class AKClassItem;
@class AKTokenItem;
@class AKSubtopic;

/*!
 * Abstract class that represents a documentation topic to which an AppKiDo
 * window can navigate. Used as the representedObject of cells in the
 * topic browser.
 *
 * UI notes: when a topic is selected in the topic browser, the selected AKTopic
 * provides **child topics** for populating the next column of the browser, and
 * **subtopics** for populating the subtopics list. For example, when a class is
 * selected in the topic browser, the child topics are the class's subclasses
 * and the subtopics are "General", "Class Methods", "Instance Methods", etc.
 */
@interface AKTopic : NSObject <AKPrefDictionary, AKSortable>

#pragma mark -
#pragma mark String constants

extern NSString *AKTopicBrowserPathSeparator;

// Names displayed in the topic browser for certain types of topics.
extern NSString *AKProtocolsTopicName;
extern NSString *AKInformalProtocolsTopicName;
extern NSString *AKFunctionsTopicName;
extern NSString *AKGlobalsTopicName;

#pragma mark -
#pragma mark Getters and setters

@property (NS_NONATOMIC_IOSONLY, readonly, strong) AKClassItem *parentClassOfTopic;  //TODO: KLUDGE

/*!
 * Returns nil if the topic is not associated with a token item.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, strong) AKTokenItem *topicItem;

#pragma mark -
#pragma mark Names for various display contexts

/*! Subclasses must override. */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringToDisplayInTopicBrowser;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringToDisplayInDescriptionField;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringToDisplayInLists;

#pragma mark -
#pragma mark Populating the topic browser

/*! Subclasses must override. */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *pathInTopicBrowser;

/*! Subclasses may override. Defaults to YES. */
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL browserCellShouldBeEnabled;

/*! Subclasses may override. Defaults to YES. */
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL browserCellHasChildren;

/*!
 * Subclasses must override if they can possibly have children. Returns array of
 * AKTopics. Note the distinction between child topics and subtopics.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *childTopics;

#pragma mark -
#pragma mark Subtopics

/*! Subclasses must override. */
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger numberOfSubtopics;

/*! Subclasses must override. */
- (AKSubtopic *)subtopicAtIndex:(NSInteger)subtopicIndex;

/*! Returns -1 if none found. */
- (NSInteger)indexOfSubtopicWithName:(NSString *)subtopicName;

- (AKSubtopic *)subtopicWithName:(NSString *)subtopicName;

@end
