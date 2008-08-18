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
    NSTextField *_devToolsPathField;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

/*! Returns an instance attached to a pre-existing UI via textField. */
+ (id)controllerWithTextField:(NSTextField *)textField;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*! Designated initializer. */
- (id)initWithTextField:(NSTextField *)textField;

//-------------------------------------------------------------------------
// Running the panel
//-------------------------------------------------------------------------

/*!
 * Does a rough sanity check on a directory that is claimed to be a
 * Dev Tools directory.
 */
+ (BOOL)looksLikeValidDevToolsPath:(NSString *)devToolsPath;

/*!
 * Displays an open panel that prompts the user for the Dev Tools location.
 * The open panel is opened as a sheet on the window containing
 * _devToolsPathField.
 */
- (void)runOpenPanel;

@end
