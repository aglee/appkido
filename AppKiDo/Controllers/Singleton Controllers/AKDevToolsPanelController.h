//
//  AKDevToolsPanelController.h
//  AppKiDo
//
//  Created by Andy Lee on 8/10/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 * Modal panel that appears on launch if we can't load our database using the
 * existing dev tools settings.
 */
@interface AKDevToolsPanelController : NSWindowController

@property (nonatomic, weak) IBOutlet NSView *devToolsView;

#pragma mark - Running the panel

/*! Prompts the user for an Xcode location.  Updates user prefs. Returns NO if the user cancels. */
+ (BOOL)runDevToolsSetupPanel;

#pragma mark - Action methods

- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;

@end
