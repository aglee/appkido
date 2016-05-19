/*
 * AKTopicBrowserViewController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKViewController.h"

@class AKBrowser;

/*!
 * Manages the NSBrowser used to navigate the top-level "topics" in an AppKiDo
 * browser window.
 */
@interface AKTopicBrowserViewController : AKViewController <NSUserInterfaceValidations, NSBrowserDelegate>
{
@private
	// Values to display in all the columns of the browser.  Each element
	// is an array of values to be displayed in one column of the browser.
	// Values are instances of AKTopic classes.
	NSMutableArray *_topicListsForBrowserColumns;
}

@property (nonatomic, weak) IBOutlet AKBrowser *topicBrowser;

#pragma mark - Action methods

- (IBAction)addBrowserColumn:(id)sender;
- (IBAction)removeBrowserColumn:(id)sender;
- (IBAction)doBrowserAction:(id)sender;

@end
