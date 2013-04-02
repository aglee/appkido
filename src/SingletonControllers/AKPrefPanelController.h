/*
 * AKPrefPanelController.h
 *
 * Created by Andy Lee on Sat Sep 07 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class AKDevToolsViewController;

/*!
 * Controller for the application-wide Preferences panel.
 */
@interface AKPrefPanelController : NSObject
{
    // Provides the controls in the Dev Tools tab.
    AKDevToolsViewController *_devToolsViewController;

    // IBOutlets -- tab view for showing groups of preference settings.
    NSTabView *_prefsTabView;

    // IBOutlets -- controls in the Appearance tab.
    NSPopUpButton *_listFontNameChoice;
    NSComboBox *_listFontSizeCombo;
    NSPopUpButton *_headerFontNameChoice;
    NSComboBox *_headerFontSizeCombo;
    NSPopUpButton *_magnificationChoice;

    // IBOutlets -- controls in the Frameworks tab.
    NSTableView *_frameworksTable;

    // IBOutlets -- controls in the Search tab.
    NSButton *_searchInNewWindowCheckbox;
}

@property (nonatomic, assign) IBOutlet NSTabView *prefsTabView;
@property (nonatomic, assign) IBOutlet NSPopUpButton *listFontNameChoice;
@property (nonatomic, assign) IBOutlet NSComboBox *listFontSizeCombo;
@property (nonatomic, assign) IBOutlet NSPopUpButton *headerFontNameChoice;
@property (nonatomic, assign) IBOutlet NSComboBox *headerFontSizeCombo;
@property (nonatomic, assign) IBOutlet NSPopUpButton *magnificationChoice;
@property (nonatomic, assign) IBOutlet NSTableView *frameworksTable;
@property (nonatomic, assign) IBOutlet NSButton *searchInNewWindowCheckbox;

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
