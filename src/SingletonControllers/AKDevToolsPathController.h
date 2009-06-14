//
//  AKDevToolsPathController.h
//  AppKiDo
//
//  Created by Andy Lee on 6/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/*!
 * Controller that is attached to a text field that displays the user's
 * preference for the Dev Tools location.  Calling -runOpenPanel starts
 * an open panel sheet in the window that contains that text field,
 * allowing the user to select a different Dev Tools path.
 */
@interface AKDevToolsPathController : NSObject
{
    IBOutlet NSTextField *_devToolsPathField;
    IBOutlet NSPopUpButton *_sdkVersionsPopUpButton;
}


#pragma mark -
#pragma mark Getters and setters

/*!
 * Does a rough sanity check on a directory that is claimed to be a
 * Dev Tools directory.
 */
+ (BOOL)looksLikeValidDevToolsPath:(NSString *)devToolsPath;


#pragma mark -
#pragma mark Action methods

/*!
 * Displays an open panel that prompts the user for the Dev Tools location.
 * The open panel is opened as a sheet on the window that contains
 * _devToolsPathField.
 */
- (IBAction)runOpenPanel:(id)sender;

/*! Called by the SDK popup button. */
- (IBAction)selectSDKVersion:(id)sender;


#pragma mark -
#pragma mark Running the panel

/*!
 * Fills in the SDK popup menu based on the Dev Tools path specified in
 * the text field.
 */
- (void)populateSDKPopUpButton;

@end
