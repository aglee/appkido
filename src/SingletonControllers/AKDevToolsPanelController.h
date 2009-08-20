//
//  AKDevToolsPanelController.h
//  AppKiDo
//
//  Created by Andy Lee on 8/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AKDevToolsPathController;

/*!
 * Controller for the panel that comes up during launch if the user's
 * prefs don't contain a valid Dev Tools path.
 */
@interface AKDevToolsPanelController : NSObject
{
    // In our nib file, _devToolsPathController's two outlets are connected
    // to _devToolsPathField and _sdkVersionsPopUpButton.
    IBOutlet AKDevToolsPathController *_devToolsPathController;
    IBOutlet NSTextField *_devToolsPathField;
    IBOutlet NSPopUpButton *_sdkVersionsPopUpButton;

    IBOutlet NSButton *_okButton;
}

#pragma mark -
#pragma mark Factory methods

+ (id)controller;


#pragma mark -
#pragma mark Running the panel

/*!
 * Either gets a valid Dev Tools path from the user or exits the application.
 * If a Dev Tools path is selected, updates the AKDevToolsPathPrefName and
 * AKSDKVersionPrefName user prefs.
 */
- (void)runDevToolsSetupPanel;


#pragma mark -
#pragma mark Action methods

- (IBAction)ok:(id)sender;

- (IBAction)cancel:(id)sender;

@end
