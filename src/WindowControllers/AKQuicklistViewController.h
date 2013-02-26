/*
 * AKQuicklistViewController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKWindowSubcontroller.h"
#import "DIGSFindBufferDelegate.h"

@class AKDocLocator;
@class AKMultiRadioView;
@class AKSearchQuery;
@class AKTableView;
@class AKWindowLayout;

/*!
 * Controller for a browser window's quicklist drawer.
 */
@interface AKQuicklistViewController : AKWindowSubcontroller <DIGSFindBufferDelegate>
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

    // UI outlets -- the "Quicklist" panel.
    IBOutlet AKMultiRadioView *_quicklistModeRadio;

    IBOutlet NSPopUpButton *_frameworkPopup;

    IBOutlet NSTextField *_searchField;
    IBOutlet NSPopUpButton *_searchOptionsPopup;
    IBOutlet NSMenuItem *_includeClassesItem;
    IBOutlet NSMenuItem *_includeMethodsItem;
    IBOutlet NSMenuItem *_includeFunctionsItem;
    IBOutlet NSMenuItem *_includeGlobalsItem;
    IBOutlet NSMenuItem *_ignoreCaseItem;
    IBOutlet NSMenuItem *_searchOptionsDividerItem;

    IBOutlet AKTableView *_quicklistTable;
    IBOutlet NSButton *_removeFavoriteButton;
}

#pragma mark -
#pragma mark Window layout

- (void)takeWindowLayoutFrom:(AKWindowLayout *)windowLayout;

- (void)putWindowLayoutInto:(AKWindowLayout *)windowLayout;

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
