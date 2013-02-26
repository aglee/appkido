/*
 * AK_TopicBrowserViewController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AK_ViewController.h"

@class AKBrowser;
@class AKDocLocator;

/*!
 * Manages the NSBrowser used to navigate the top-level "topics" in an AppKiDo
 * browser window.
 */
@interface AK_TopicBrowserViewController : AK_ViewController
{
@private
    // Values to display in all the columns of the browser.  Each element
    // is an array of values to be displayed in one column of the browser.
    // Values are instances of AKTopic classes.
    NSMutableArray *_topicListsForBrowserColumns;

    // IBOutlets.
    AKBrowser *_topicBrowser;
}

@property (nonatomic, assign) IBOutlet AKBrowser *topicBrowser;

#pragma mark -
#pragma mark Navigation

/*! May modify whereTo. */
- (void)navigateFrom:(AKDocLocator *)whereFrom to:(AKDocLocator *)whereTo;

#pragma mark -
#pragma mark Action methods

- (IBAction)addBrowserColumn:(id)sender;

- (IBAction)removeBrowserColumn:(id)sender;

/*! Called when the user selects a topic in the topic browser. */
- (IBAction)doBrowserAction:(id)sender;

@end
