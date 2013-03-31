/*
 * AKTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSortable.h"
#import "AKPrefDictionary.h"
#import "AKPrefUtils.h"

@class AKClassNode;
@class AKDatabaseNode;
@class AKSubtopic;

/*!
 * @class       AKTopic
 * @abstract    The representedObject of cells in the topic browser.
 * @discussion  Each cell in the topic browser uses an AKTopic as its
 *              representedObject.  (The topic browser is the NSBrowserView
 *              at the top of the window.  It is managed by an
 *              AKTopicBrowserController.)
 *
 *              When a topic is selected in the browser, the selected
 *              AKTopic knows how to populate the next column in the
 *              browser.  The AKTopic also generates AKSubtopic instances
 *              used to populate the subtopic list.  (The subtopic list is
 *              the NSTableView on the left side of the middle section of
 *              the window; it is managed by an AKSubtopicListController.)
 *
 *              For example, when a class is selected in the topic browser,
 *              the next column of the browser is populated with the
 *              class's subclasses, and the subtopic list is populated with
 *              subtopics related to the class like "Class Methods",
 *              "Instance Methods", and so forth.
 *
 *              AKTopic is an abstract class.
 */
@interface AKTopic : NSObject <AKPrefDictionary, AKSortable>

#pragma mark -
#pragma mark AKXyzTopicName

extern NSString *AKTopicBrowserPathSeparator;

// Canned strings displayed in the topic browser for certain types of topics.
extern NSString *AKProtocolsTopicName;
extern NSString *AKInformalProtocolsTopicName;
extern NSString *AKFunctionsTopicName;
extern NSString *AKGlobalsTopicName;

#pragma mark -
#pragma mark Getters and setters

// [agl] KLUDGE
- (AKClassNode *)parentClassOfTopic;

/*!
 * Returns nil by default.  Subclasses return a node, if one is relevant.
 * Specifically, AKBehaviorTopics return AKBehaviorNodes.
 */
- (AKDatabaseNode *)topicNode;

#pragma mark -
#pragma mark Names for various display contexts

/*! Subclasses must override. */
- (NSString *)stringToDisplayInTopicBrowser;

- (NSString *)stringToDisplayInDescriptionField;

- (NSString *)stringToDisplayInLists;

#pragma mark -
#pragma mark Populating the topic browser

/*! Subclasses must override. */
- (NSString *)pathInTopicBrowser;

/*! Subclasses may override. Defaults to YES. */
- (BOOL)browserCellShouldBeEnabled;

/*! Subclasses may override. Defaults to YES. */
- (BOOL)browserCellHasChildren;

/*!
 * Subclasses must override if they may have children. Returns array of
 * AKTopics.
 */
- (NSArray *)childTopics;

#pragma mark -
#pragma mark Populating the subtopics table

/*! Subclasses must override. */
- (NSInteger)numberOfSubtopics;

/*! Subclasses must override. May not return the same object every time. */
- (AKSubtopic *)subtopicAtIndex:(NSInteger)subtopicIndex;

- (NSInteger)indexOfSubtopicWithName:(NSString *)subtopicName;

- (AKSubtopic *)subtopicWithName:(NSString *)subtopicName;

@end
