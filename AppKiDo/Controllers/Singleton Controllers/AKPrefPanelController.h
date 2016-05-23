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
    NSTabView *__weak _prefsTabView;

    // IBOutlets -- controls in the Appearance tab.
    NSPopUpButton *__weak _listFontNameChoice;
    NSComboBox *__weak _listFontSizeCombo;
    NSPopUpButton *__weak _headerFontNameChoice;
    NSComboBox *__weak _headerFontSizeCombo;
    NSPopUpButton *__weak _magnificationChoice;

    // IBOutlets -- controls in the Frameworks tab.
    NSTableView *__weak _frameworksTable;

    // IBOutlets -- controls in the Search tab.
    NSButton *__weak _searchInNewWindowCheckbox;
}

@property (nonatomic, weak) IBOutlet NSTabView *prefsTabView;
@property (nonatomic, weak) IBOutlet NSPopUpButton *listFontNameChoice;
@property (nonatomic, weak) IBOutlet NSComboBox *listFontSizeCombo;
@property (nonatomic, weak) IBOutlet NSPopUpButton *headerFontNameChoice;
@property (nonatomic, weak) IBOutlet NSComboBox *headerFontSizeCombo;
@property (nonatomic, weak) IBOutlet NSPopUpButton *magnificationChoice;
@property (nonatomic, weak) IBOutlet NSTableView *frameworksTable;
@property (nonatomic, weak) IBOutlet NSButton *searchInNewWindowCheckbox;

#pragma mark - Factory methods

+ (AKPrefPanelController *)sharedInstance;

#pragma mark - Action methods

- (IBAction)openPrefsPanel:(id)sender;

- (IBAction)applyAppearancePrefs:(id)sender;

- (IBAction)useDefaultAppearancePrefs:(id)sender;

- (IBAction)doFrameworksListAction:(id)sender;

- (IBAction)selectAllFrameworks:(id)sender;

- (IBAction)deselectAllFrameworks:(id)sender;

- (IBAction)toggleShouldSearchInNewWindow:(id)sender;

@end
