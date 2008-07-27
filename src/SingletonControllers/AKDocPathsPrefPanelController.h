//
//  AKDocPathsPrefPanelController.h
//  AppKiDo
//
//  Created by Andy Lee on 6/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AKDocPathsPrefPanelController : NSObject
{
    IBOutlet NSWindow *_docPathsPrefPanel;
    IBOutlet NSTextField *_devToolsPathField;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

/*!
 * @method      sharedInstance
 * @discussion  Returns the one and only instance of this class.
 */
+ (AKDocPathsPrefPanelController *)sharedInstance;

//-------------------------------------------------------------------------
// Running the panel
//-------------------------------------------------------------------------

/*!
 * Runs an application-modal panel that allows the user to set prefs that
 * tell us where to find documentation.  Returns YES if the user accepts
 * the panel (only possible if the inputs are valid).  Returns NO if the
 * user cancels.
 */
- (BOOL)runPanel;

@end
