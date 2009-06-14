//
//  AKDevToolsPathController.h
//  AppKiDo
//
//  Created by Andy Lee on 6/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/*!
 * Manages the UI used for specifying which docset the application should load.
 * The user selects a Dev Tools path (e.g., /Developer) and an SDK version
 * (e.g., 10.5 for Mac OS or 3.0 for iPhone SDK).  The choice of SDK versions
 * depends on what we find in the Dev Tools path.
 *
 * This UI is used in two places: (1) the modal window that appears on
 * application launch if we can't find the docset specified by the user's prefs,
 * and (2) the Dev Tools tab of the preferences window.
 */
@interface AKDevToolsPathController : NSObject
{
    IBOutlet NSTextField *_devToolsPathField;
    IBOutlet NSPopUpButton *_sdkVersionsPopUpButton;
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


#pragma mark -
#pragma mark Running the panel

/*!
 * Fills in the popup button that lists available SDK versions.  Gets this list
 * by looking in the directory specified by the AKDevToolsPathPrefName user pref.
 */
- (void)populateSDKPopUpButton;

@end
