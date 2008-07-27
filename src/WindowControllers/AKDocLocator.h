/*
 * AKDocLocator.h
 *
 * Created by Andy Lee on Tue May 27 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

#import "AKSortable.h"

@class AKFileSection;
@class AKDoc;
@class AKTopic;

/*!
 * @class       AKDocLocator
 * @discussion  Base class for objects representing states the user can
 *              navigate to in a browser window.
 */
@interface AKDocLocator : NSObject <AKSortable>
{
    // The topic selected in the window's topic browser.
    AKTopic *_topic;

    // The selected item in the window's subtopics table.
    NSString *_subtopicName;

    // The selected item in the window's doc list.
    NSString *_docName;

    NSString *_cachedDisplayString;
    NSString *_cachedSortName;
    AKDoc *_cachedDoc;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)withTopic:(AKTopic *)topic
    subtopicName:(NSString *)subtopicName
    docName:(NSString *)docName;

//-------------------------------------------------------------------------
// Preferences
//-------------------------------------------------------------------------

+ (id)fromPrefDictionary:(NSDictionary *)prefDict;

- (NSDictionary *)asPrefDictionary;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithTopic:(AKTopic *)topic
    subtopicName:(NSString *)subtopicName
    docName:(NSString *)docName;

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (AKTopic *)topicToDisplay;

- (NSString *)subtopicName;

- (void)setSubtopicName:(NSString *)subtopicName;

- (NSString *)docName;

- (void)setDocName:(NSString *)docName;

- (NSString *)stringToDisplayInLists;

- (AKDoc *)docToDisplay;

//-------------------------------------------------------------------------
// Sorting
//-------------------------------------------------------------------------

// *Should* be equivalent to using the -sortName mechanism, but faster.
+ (void)sortArrayOfDocLocators:(NSMutableArray *)array;

//-------------------------------------------------------------------------
// AKSortable methods
//-------------------------------------------------------------------------

- (NSString *)sortName;

@end
