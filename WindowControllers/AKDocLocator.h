/*
 * AKDocLocator.h
 *
 * Created by Andy Lee on Tue May 27 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import "AKPrefDictionary.h"
#import "AKSortable.h"


@class AKDoc;
@class AKTopic;

/*!
 * Represents an AppKiDo window's navigational state as a three-component path:
 *
 *  - a selected topic (never nil)
 *  - a subtopic within that topic (possibly nil)
 *  - if the subtopic is non-nil, a doc within that subtopic (possibly nil)
 *
 * Doc locators are used in various navigation lists presented to the user, such
 * as search results and popup menus (go to superclass, go back, go forward).
 * Doc locators are also part of the saved state that we use to restore windows
 * when the app relaunches (see AKSavedWindowState).
 *
 * The term "locator" suggests rough conceptual similarity to a URL.
 */
@interface AKDocLocator : NSObject <AKPrefDictionary, AKSortable>
{
@private
    AKTopic *_topic;
    NSString *_subtopicName;
    NSString *_docName;

    NSString *_cachedDisplayString;
    NSString *_cachedSortName;
    AKDoc *_cachedDoc;
}

@property (NS_NONATOMIC_IOSONLY, readonly, strong) AKTopic *topicToDisplay;
@property (NS_NONATOMIC_IOSONLY, copy) NSString *subtopicName;
@property (NS_NONATOMIC_IOSONLY, copy) NSString *docName;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringToDisplayInLists;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) AKDoc *docToDisplay;


#pragma mark -
#pragma mark Factory methods

+ (id)withTopic:(AKTopic *)topic subtopicName:(NSString *)subtopicName docName:(NSString *)docName;

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithTopic:(AKTopic *)topic subtopicName:(NSString *)subtopicName docName:(NSString *)docName NS_DESIGNATED_INITIALIZER;

#pragma mark -
#pragma mark Sorting

/*! *Should* be equivalent to using the -sortName mechanism, but faster. */
+ (void)sortArrayOfDocLocators:(NSMutableArray *)array;

@end
