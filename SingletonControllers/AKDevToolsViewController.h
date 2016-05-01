//
//  AKDevToolsPrefsViewController.h
//  AppKiDo
//
//  Created by Andy Lee on 6/17/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 * Manages the UI used for specifying Dev Tools settings. The users tells us
 * where Xcode.app is and we figure out what kind of Dev Tools installation that
 * implies (/Applications-style or /Developer-style). The user then selects one
 * of the SDK versions supported by that Dev Tools installation.
 *
 * This view is used in two places: in the "Dev Tools" tab of the prefs panel,
 * and in the modal panel that appears on launch if we can't load our database
 * using the existing dev tools settings.
 */
@interface AKDevToolsViewController : NSViewController <NSOpenSavePanelDelegate>
{
@private
    NSString *_selectedXcodeAppPath;

    // IBOutlets.
    NSTextField *__weak _xcodeAppPathField;
    NSButton *__weak _locateXcodeButton;
    NSPopUpButton *__weak _sdkVersionsPopUpButton;
    NSTextField *__weak _explanationField;
    NSButton *__weak _okButton;  // Present only in the Dev Tools Panel.
}

@property (nonatomic, weak) IBOutlet NSTextField *xcodeAppPathField;
@property (nonatomic, weak) IBOutlet NSButton *locateXcodeButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *sdkVersionsPopUpButton;
@property (nonatomic, weak) IBOutlet NSTextField *explanationField;
@property (nonatomic, weak) IBOutlet NSButton *okButton;

#pragma mark - Action methods

/*!
 * Repeatedly displays an open panel sheet until the user either cancels or
 * selects a valid Xcode app bundle.
 */
- (IBAction)promptForXcodeLocation:(id)sender;

/*! Called by the popup button that lists available SDK versions. */
- (IBAction)selectSDKVersion:(id)sender;

@end
