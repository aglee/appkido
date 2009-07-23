/*
 * AKTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSortable.h"
#import "AKPrefUtils.h"

@class AKSubtopic;
@class AKDatabase;
@class AKDatabaseNode;
@class AKClassNode;
@class AKSubtopic;
@class AKDoc;

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
@interface AKTopic : NSObject <AKSortable>
{
}


#pragma mark -
#pragma mark AKXyzTopicName

extern NSString *AKTopicBrowserPathSeparator;

// Canned strings displayed in the topic browser for certain types of
// topics.
extern NSString *AKProtocolsTopicName;
extern NSString *AKInformalProtocolsTopicName;
extern NSString *AKFunctionsTopicName;
extern NSString *AKGlobalsTopicName;


#pragma mark -
#pragma mark Preferences

/*!
 * @method      fromPrefDictionary:
 * @discussion  Returns an instance that has been initialized with the
 *              contents of prefDict.
 */
+ (AKTopic *)fromPrefDictionary:(NSDictionary *)prefDict;

/*!
 * @method      asPrefDictionary
 * @discussion  Returns a dictionary suitable for use by NSUserDefaults.
 *              Uses the same dictionary structure as +fromPrefDictionary.
 */
// [agl] note className should always be in the dict
- (NSDictionary *)asPrefDictionary;


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

// subclasses must override
- (NSString *)stringToDisplayInTopicBrowser;

- (NSString *)stringToDisplayInDescriptionField;

- (NSString *)stringToDisplayInLists;


#pragma mark -
#pragma mark Populating the topic browser

// subclasses must override
- (NSString *)pathInTopicBrowser;

// subclasses may override; defaults to YES
- (BOOL)browserCellShouldBeEnabled;

// subclasses may override; defaults to YES
- (BOOL)browserCellHasChildren;

// subclasses must override if they may have children
// returns array of AKTopics
- (NSArray *)childTopics;


#pragma mark -
#pragma mark Populating the subtopics table

// subclasses must override
- (int)numberOfSubtopics;

// subclasses must override; not guaranteed to return the same instance
// every time
- (AKSubtopic *)subtopicAtIndex:(int)subtopicIndex;

- (int)indexOfSubtopicWithName:(NSString *)subtopicName;

- (AKSubtopic *)subtopicWithName:(NSString *)subtopicName;

@end
