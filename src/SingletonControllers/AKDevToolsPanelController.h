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
    AKDevToolsPathController *_textFieldController;

    IBOutlet NSTextField *_devToolsPathField;
    IBOutlet NSPopUpButton *_docSetsPopUpButton;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)controller;

//-------------------------------------------------------------------------
// Running the panel
//-------------------------------------------------------------------------

- (void)promptForDevToolsPath;

//-------------------------------------------------------------------------
// Action methods
//-------------------------------------------------------------------------

- (IBAction)runOpenPanel:(id)sender;

- (IBAction)ok:(id)sender;

- (IBAction)cancel:(id)sender;

@end
