/*
 * AKQuicklistViewController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKViewController.h"
#import "DIGSFindBufferDelegate.h"
#import "AKMultiRadioViewDelegate.h"

@class AKDocLocator;
@class AKMultiRadioView;
@class AKSearchQuery;
@class AKTableView;
@class AKWindowLayout;

/*!
 * Controller for a browser window's quicklist drawer.
 */
@interface AKQuicklistViewController : AKViewController <DIGSFindBufferDelegate, AKMultiRadioViewDelegate, NSTableViewDelegate, NSTableViewDataSource, NSUserInterfaceValidations>
{
@private
    // AKDocLocator objects listed in _quicklistTable.
    NSArray *_docLocators;

    // Criterion used to populate _quicklistTable, as selected from
    // _quicklistModeMatrix.
    NSInteger _selectedQuicklistMode;

    // For managing searches and search results.
    NSInteger _indexWithinSearchResults;
    AKSearchQuery *_searchQuery;
    NSMutableArray *_pastSearchStrings;

    // IBOutlets.
    AKMultiRadioView *__weak _quicklistModeRadio;
    NSMatrix *__weak _quicklistRadio1;
    NSMatrix *__weak _quicklistRadio2;
    NSMatrix *__weak _quicklistRadio3;

    NSPopUpButton *__weak _frameworkPopup;

    NSTextField *__weak _searchField;
    NSPopUpButton *__weak _searchOptionsPopup;
    NSMenuItem *__weak _includeClassesItem;
    NSMenuItem *__weak _includeMethodsItem;
    NSMenuItem *__weak _includeFunctionsItem;
    NSMenuItem *__weak _includeGlobalsItem;
    NSMenuItem *__weak _ignoreCaseItem;
    NSMenuItem *__weak _searchOptionsDividerItem;

    AKTableView *__weak _quicklistTable;
    NSButton *__weak _removeFavoriteButton;
}

@property (nonatomic, weak) IBOutlet AKMultiRadioView *quicklistModeRadio;
@property (nonatomic, weak) IBOutlet NSMatrix *quicklistRadio1;
@property (nonatomic, weak) IBOutlet NSMatrix *quicklistRadio2;
@property (nonatomic, weak) IBOutlet NSMatrix *quicklistRadio3;
@property (nonatomic, weak) IBOutlet NSPopUpButton *frameworkPopup;
@property (nonatomic, weak) IBOutlet NSTextField *searchField;
@property (nonatomic, weak) IBOutlet NSPopUpButton *searchOptionsPopup;
@property (nonatomic, weak) IBOutlet NSMenuItem *includeClassesItem;
@property (nonatomic, weak) IBOutlet NSMenuItem *includeMethodsItem;
@property (nonatomic, weak) IBOutlet NSMenuItem *includeFunctionsItem;
@property (nonatomic, weak) IBOutlet NSMenuItem *includeGlobalsItem;
@property (nonatomic, weak) IBOutlet NSMenuItem *ignoreCaseItem;
@property (nonatomic, weak) IBOutlet NSMenuItem *searchOptionsDividerItem;
@property (nonatomic, weak) IBOutlet AKTableView *quicklistTable;
@property (nonatomic, weak) IBOutlet NSButton *removeFavoriteButton;

#pragma mark - Navigation

- (void)searchForString:(NSString *)aString;

- (void)includeEverythingInSearch;

#pragma mark - Action methods

- (IBAction)doQuicklistTableAction:(id)sender;

- (IBAction)doFrameworkChoiceAction:(id)sender;

- (IBAction)removeFavorite:(id)sender;

- (IBAction)selectSearchField:(id)sender;

- (IBAction)doSearch:(id)sender;

- (IBAction)doSearchOptionsPopupAction:(id)sender;

@end
