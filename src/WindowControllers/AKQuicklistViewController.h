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
@interface AKQuicklistViewController : AKViewController <DIGSFindBufferDelegate, AKMultiRadioViewDelegate>
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
    AKMultiRadioView *_quicklistModeRadio;
    NSMatrix *_quicklistRadio1;
    NSMatrix *_quicklistRadio2;
    NSMatrix *_quicklistRadio3;

    NSPopUpButton *_frameworkPopup;

    NSTextField *_searchField;
    NSPopUpButton *_searchOptionsPopup;
    NSMenuItem *_includeClassesItem;
    NSMenuItem *_includeMethodsItem;
    NSMenuItem *_includeFunctionsItem;
    NSMenuItem *_includeGlobalsItem;
    NSMenuItem *_ignoreCaseItem;
    NSMenuItem *_searchOptionsDividerItem;

    AKTableView *_quicklistTable;
    NSButton *_removeFavoriteButton;
}

@property (nonatomic, assign) IBOutlet AKMultiRadioView *quicklistModeRadio;
@property (nonatomic, assign) IBOutlet NSMatrix *quicklistRadio1;
@property (nonatomic, assign) IBOutlet NSMatrix *quicklistRadio2;
@property (nonatomic, assign) IBOutlet NSMatrix *quicklistRadio3;
@property (nonatomic, assign) IBOutlet NSPopUpButton *frameworkPopup;
@property (nonatomic, assign) IBOutlet NSTextField *searchField;
@property (nonatomic, assign) IBOutlet NSPopUpButton *searchOptionsPopup;
@property (nonatomic, assign) IBOutlet NSMenuItem *includeClassesItem;
@property (nonatomic, assign) IBOutlet NSMenuItem *includeMethodsItem;
@property (nonatomic, assign) IBOutlet NSMenuItem *includeFunctionsItem;
@property (nonatomic, assign) IBOutlet NSMenuItem *includeGlobalsItem;
@property (nonatomic, assign) IBOutlet NSMenuItem *ignoreCaseItem;
@property (nonatomic, assign) IBOutlet NSMenuItem *searchOptionsDividerItem;
@property (nonatomic, assign) IBOutlet AKTableView *quicklistTable;
@property (nonatomic, assign) IBOutlet NSButton *removeFavoriteButton;

#pragma mark -
#pragma mark Navigation

- (void)searchForString:(NSString *)aString;

- (void)includeEverythingInSearch;

#pragma mark -
#pragma mark Action methods

- (IBAction)doQuicklistTableAction:(id)sender;

- (IBAction)doFrameworkChoiceAction:(id)sender;

- (IBAction)removeFavorite:(id)sender;

- (IBAction)selectSearchField:(id)sender;

- (IBAction)doSearch:(id)sender;

- (IBAction)doSearchOptionsPopupAction:(id)sender;

@end
