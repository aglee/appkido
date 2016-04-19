//
//  AKDevToolsPanelController.h
//  AppKiDo
//
//  Created by Andy Lee on 8/10/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AKDevToolsViewController;

/*!
 * Modal panel that appears on launch if we can't load our database using the
 * existing dev tools settings.
 */
@interface AKDevToolsPanelController : NSWindowController
{
@private
    AKDevToolsViewController *_devToolsViewController;

    // IBOutlets.
    NSView *__weak _devToolsView;  // A placeholder in the nib; the real view is swapped in after the nib is loaded.
    NSButton *__weak _okButton;  // We connect this to _devToolsViewController.
}

@property (nonatomic, weak) IBOutlet NSView *devToolsView;
@property (nonatomic, weak) IBOutlet NSButton *okButton;

#pragma mark -
#pragma mark Running the panel

/*!
 * Prompts the user to specify an Xcode location and an SDK, and updates user
 * prefs accordingly. Returns NO if the user cancels.
 */
+ (BOOL)runDevToolsSetupPanel;

#pragma mark -
#pragma mark Action methods

- (IBAction)ok:(id)sender;

- (IBAction)cancel:(id)sender;

@end
