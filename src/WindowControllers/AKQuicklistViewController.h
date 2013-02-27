/*
 * AKQuicklistViewController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKViewController.h"
#import "DIGSFindBufferDelegate.h"

@class AKDocLocator;
@class AKMultiRadioView;
@class AKSearchQuery;
@class AKTableView;
@class AKWindowLayout;

/*!
 * Controller for a browser window's quicklist drawer.
 */
@interface AKQuicklistViewController : AKViewController <DIGSFindBufferDelegate>
{
@private
    // Contains the values currently displayed in _quicklistTable.  Elements
    // are AKDocLocators.
    NSArray *_currentTableValues;

    // Criterion used to populate _quicklistTable, as selected from
    // _quicklistModeMatrix.
    NSInteger _currentQuicklistMode;

    // For managing searches and search results.
    NSInteger _indexWithinSearchResults;
    AKSearchQuery *_searchQuery;
    NSMutableArray *_pastSearchStrings;

    // IBOutlets.
    AKMultiRadioView *_quicklistModeRadio;

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

#pragma mark -
#pragma mark Action methods

- (IBAction)doQuicklistModeMatrixAction:(id)sender;

- (IBAction)doQuicklistTableAction:(id)sender;

- (IBAction)doFrameworkChoiceAction:(id)sender;

- (IBAction)removeFavorite:(id)sender;

- (IBAction)selectSearchField:(id)sender;

- (IBAction)doSearch:(id)sender;

- (IBAction)doSearchOptionsPopupAction:(id)sender;

- (IBAction)selectPreviousSearchResult:(id)sender;

- (IBAction)selectNextSearchResult:(id)sender;




#pragma mark -
#pragma mark Action methods -- search (forwarded to the quicklist controller)

- (IBAction)selectSearchField:(id)sender;

- (IBAction)selectPreviousSearchResult:(id)sender;

- (IBAction)selectNextSearchResult:(id)sender;




@end
