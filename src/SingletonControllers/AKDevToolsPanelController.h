//
//  AKDevToolsPanelController.h
//  AppKiDo
//
//  Created by Andy Lee on 8/10/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AKDevToolsPathController;

/*!
 * Controller for the panel that comes up during launch if the user's
 * prefs don't contain a valid Dev Tools path.
 *
 * [agl] FIXME It would be better to use this same class both as needed
 * during launch and as a sheet in the prefs window (which is currently
 * modeless, which means it allows saving an invalid directory). Can
 * redesign if and when all this gets converted to NSWindowControllers
 * and NSViewControllers etc.
 */
@interface AKDevToolsPanelController : NSObject
{
@private
    IBOutlet NSWindow *_window;
    IBOutlet AKDevToolsPathController *_devToolsPathController;
}

#pragma mark -
#pragma mark Factory methods

+ (id)controller;

#pragma mark -
#pragma mark Running the panel

/*!
 * Prompts the user for a valid Dev Tools path.  If a Dev Tools path is selected,
 * updates the AKDevToolsPathPrefName and AKSDKVersionPrefName user prefs and
 * returns YES.  If the user cancels, returns NO.
 */
- (BOOL)runDevToolsSetupPanel;

#pragma mark -
#pragma mark Action methods

- (IBAction)ok:(id)sender;

- (IBAction)cancel:(id)sender;

@end
