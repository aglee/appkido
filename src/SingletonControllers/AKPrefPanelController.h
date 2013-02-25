/*
 * AKPrefPanelController.h
 *
 * Created by Andy Lee on Sat Sep 07 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class AKDevToolsPathController;

/*!
 * Controller for the application-wide Preferences panel.
 */
@interface AKPrefPanelController : NSObject
{
    // Tab view for switching between groups of preference settings.
    IBOutlet NSTabView *_prefsTabView;

    // Controls in the Appearance tab.
    IBOutlet NSPopUpButton *_listFontNameChoice;
    IBOutlet NSComboBox *_listFontSizeCombo;

    IBOutlet NSPopUpButton *_headerFontNameChoice;
    IBOutlet NSComboBox *_headerFontSizeCombo;

    IBOutlet NSPopUpButton *_magnificationChoice;

    // Controls in the Frameworks tab.
    IBOutlet NSTableView *_frameworksTable;

    // Controls in the Dev Tools tab.
    // In our nib file, _devToolsPathController's two outlets are connected
    // to _xcodeAppPathField and _sdkVersionsPopUpButton.
    IBOutlet AKDevToolsPathController *_devToolsPathController;
    IBOutlet NSTextField *_xcodeAppPathField;
    IBOutlet NSPopUpButton *_sdkVersionsPopUpButton;
    
    // Controls in the Search tab.
    IBOutlet NSButton *_searchInNewWindowCheckbox;
}

#pragma mark -
#pragma mark Factory methods

+ (AKPrefPanelController *)sharedInstance;

#pragma mark -
#pragma mark Action methods

- (IBAction)openPrefsPanel:(id)sender;

- (IBAction)applyAppearancePrefs:(id)sender;

- (IBAction)useDefaultAppearancePrefs:(id)sender;

- (IBAction)doFrameworksListAction:(id)sender;

- (IBAction)selectAllFrameworks:(id)sender;

- (IBAction)deselectAllFrameworks:(id)sender;

- (IBAction)toggleShouldSearchInNewWindow:(id)sender;

@end
