/*
 * AKTopicBrowserViewController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKViewController.h"

/*!
 * Manages the NSBrowser used to navigate the top-level "topics".
 */
@interface AKTopicBrowserViewController : AKViewController <NSUserInterfaceValidations, NSBrowserDelegate>

@property (weak) IBOutlet NSBrowser *topicBrowser;

#pragma mark - Action methods

- (IBAction)addBrowserColumn:(id)sender;
- (IBAction)removeBrowserColumn:(id)sender;
- (IBAction)doBrowserAction:(id)sender;

@end
