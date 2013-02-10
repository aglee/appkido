//
//  AKDevToolsPathController.h
//  AppKiDo
//
//  Created by Andy Lee on 6/17/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/*!
 * Manages the UI used for specifying which docset the application should load.
 * The user specifies how (and, if necessary, where) the Dev Tools are installed.
 * The user then selects one of the SDK versions supported by that Dev Tools
 * installation (e.g., 10.7 for Mac OS or 5.0 for iPhone SDK).
 *
 * This UI is used in two places: (1) the modal window that appears on application
 * launch if we can't find the docset specified by the user's prefs (DevToolsPath.xib);
 * and (2) the Dev Tools tab of the preferences window (Pref.xib). The design of this
 * controller class is fragile in that if I add outlets I have to remember to add them
 * in both nibs.
 */
@interface AKDevToolsPathController : NSObject
{
    IBOutlet NSMatrix *_devToolsInstallationTypeMatrix;  // tag=0 means /Applications/Xcode.app, tag=1 means old-style /Developer
    IBOutlet NSTextField *_devToolsPathField;
    IBOutlet NSButton *_selectPathButton;
    IBOutlet NSPopUpButton *_sdkVersionsPopUpButton;
    IBOutlet NSTextField *_explanationField;
    IBOutlet NSButton *_okButton;  // Present only in the Locate Dev Tools window.
}


#pragma mark -
#pragma mark Action methods

/*!
 * Repeatedly displays an open panel sheet until the user either cancels or
 * selects a valid Dev Tools directory.
 */
- (IBAction)runOpenPanel:(id)sender;

/*!
 * Called by the popup button that lists available SDK versions.
 */
- (IBAction)selectSDKVersion:(id)sender;

@end
