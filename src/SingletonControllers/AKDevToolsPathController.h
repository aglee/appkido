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
 *
 * Before calling -runOpenPanel, call -setDevToolsPathField: and
 * -setDocSetsPopUpButton: to get the UI hooked up.
 */
@interface AKDevToolsPathController : NSObject
{
    NSTextField *_devToolsPathField;
    NSPopUpButton *_docSetsPopUpButton;
}


#pragma mark -
#pragma mark Getters and setters

- (void)setDevToolsPathField:(NSTextField *)textField;
- (void)setDocSetsPopUpButton:(NSPopUpButton *)popUpButton;

/*!
 * Does a rough sanity check on a directory that is claimed to be a
 * Dev Tools directory.
 */
+ (BOOL)looksLikeValidDevToolsPath:(NSString *)devToolsPath;


#pragma mark -
#pragma mark Running the panel

/*!
 * Displays an open panel that prompts the user for the Dev Tools location.
 * The open panel is opened as a sheet on the window that contains
 * _devToolsPathField.
 */
- (void)runOpenPanel;

@end
