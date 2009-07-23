/*
 * AKTopicBrowserController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <AppKit/AppKit.h>

#import "AKWindowSubcontroller.h"

@class AKBrowser;
@class AKSubtopicListController;
@class AKDocLocator;

/*!
 * @class       AKTopicBrowserController
 * @abstract    Controller for a browser window's topic browser.
 * @discussion  An AKTopicBrowserController is one of the subordinate
 *              controller objects owned by an AKWindowController.  It
 *              manages an NSBrowser used to navigate the framework
 *              database.
 */
@interface AKTopicBrowserController : AKWindowSubcontroller
{
    // Values to display in all the columns of the browser.  Each element
    // is an array of values to be displayed in one column of the browser.
    // Values are instances of AKTopic classes.
    NSMutableArray *_topicListsForBrowserColumns;

    // Outlet to subordinate controller that manages the subtopics table.
    IBOutlet AKSubtopicListController *_subtopicListController;

    // UI outlets.
    IBOutlet AKBrowser *_topicBrowser;
    IBOutlet NSTextField *_topicDescriptionField;
}


#pragma mark -
#pragma mark Navigation

// may modify whereTo
- (void)navigateFrom:(AKDocLocator *)whereFrom to:(AKDocLocator *)whereTo;

/*!
 * @method      jumpToSubtopicWithIndex:
 * @discussion  A pass-through method.  Forwards the message to my
 *   subtopics controller.
 */
- (void)jumpToSubtopicWithIndex:(int)subtopicIndex;


#pragma mark -
#pragma mark Action methods

- (IBAction)removeBrowserColumn:(id)sender;

- (IBAction)addBrowserColumn:(id)sender;

/*!
 * @method      doBrowserAction:
 * @discussion  Tells my subordinate controllers to reflect the topic
 *   selected in the topic browser.
 * @param       sender
 */
- (IBAction)doBrowserAction:(id)sender;

@end
