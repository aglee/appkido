/*
 * AKQuicklistViewController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKQuicklistViewController.h"
#import "AKAppDelegate.h"
#import "AKClassToken.h"
#import "AKClassTopic.h"
#import "AKDatabase.h"
#import "AKDocLocator.h"
#import "AKFrameworkConstants.h"
#import "AKMethodToken.h"
#import "AKMultiRadioView.h"
#import "AKPrefUtils.h"
#import "AKPropertyToken.h"
#import "AKProtocolToken.h"
#import "AKProtocolTopic.h"
#import "AKSearchQuery.h"
#import "AppKiDoTableView.h"
#import "AKWindowController.h"
#import "AKWindowLayout.h"
#import "DIGSFindBuffer.h"
#import "DIGSLog.h"
#import "NSArray+AppKiDo.h"
#import "NSSet+AppKiDo.h"
#import "NSString+AppKiDo.h"

#pragma mark - Private constants

// Pasteboard type used for drag and drop when the quicklist is in Favorites mode.
static NSString *_AKQuicklistPasteboardType = @"AKQuicklistPasteboard";

// Cell tags for the radio buttons used for selecting the quicklist mode.
enum
{
	_AKFavoritesQuicklistMode = 0,
	_AKCollectionClassesQuicklistMode = 1,
	_AKWindowOrViewControllerClassesQuicklistMode = 2,
	_AKViewClassesQuicklistMode = 3,
	_AKCellOrLayerClassesQuicklistMode = 4,
	_AKClassesWithDelegatesQuicklistMode = 5,
	_AKClassesWithDataSourcesQuicklistMode = 7,
	_AKDataSourceProtocolsQuicklistMode = 8,
	_AKAllClassesInFrameworkQuicklistMode = 9,
	_AKSearchResultsQuicklistMode = 10,
};

@interface AKQuicklistViewController ()
// The objects listed in quicklistTable.
@property (nonatomic, strong) NSArray *docLocators;
// Tells us what to put in quicklistTable.  Selected via quicklistModeMatrix.
@property (assign) NSInteger selectedQuicklistMode;
@property (nonatomic, strong) NSArray *lastSearchResults;
// Remembers the selected index in the search results list, so we can do
// Find Previous and Find Next.
@property (assign) NSInteger indexWithinLastSearchResults;
// A limited-length history of previously used search strings.
@property (nonatomic, strong) NSMutableArray *pastSearchStrings;
@end

@implementation AKQuicklistViewController

#pragma mark - Init/dealloc/awake

- (instancetype)initWithNibName:nibName windowController:(AKWindowController *)windowController
{
	self = [super initWithNibName:@"QuicklistView" windowController:windowController];
	if (self) {
		_docLocators = @[];
		_selectedQuicklistMode = -1;
		_indexWithinLastSearchResults = -1;
		_pastSearchStrings = [[NSMutableArray alloc] init];

		[[DIGSFindBuffer sharedInstance] addDelegate:self];
	}
	return self;
}

- (void)dealloc
{
	[[DIGSFindBuffer sharedInstance] removeDelegate:self];
}

- (void)awakeFromNib
{
#if APPKIDO_FOR_IPHONE
	// iOS doesn't have window or cell classes, so we substitute view controller
	// and layer classes when compiling AppKiDo-for-iPhone.
	NSButtonCell *cell;

	cell = [_quicklistRadio1 cellWithTag:_AKWindowOrViewControllerClassesQuicklistMode];
	[cell setTitle:@"View controller classes"];

	cell = [_quicklistRadio1 cellWithTag:_AKCellOrLayerClassesQuicklistMode];
	[cell setTitle:@"Layer classes"];
#endif

	// Set up _quicklistTable to do drag and drop.
	[_quicklistTable registerForDraggedTypes:@[_AKQuicklistPasteboardType]];

	// Set up the popup menu of frameworks for the "Classes in framework:"
	// quicklist item.
	// Note that the IB default for popup buttons is to autoenable items.
	// We don't want that.
	[_frameworkPopup setAutoenablesItems:NO];
	for (NSString *fwName in self.owningWindowController.database.sortedFrameworkNames) {
		[_frameworkPopup addItemWithTitle:fwName];
	}

	// Initialize the search field to match the system find-pasteboard.
	_searchField.stringValue = [DIGSFindBuffer sharedInstance].findString;

	// Match the search options popup to the user's preferences.
	_includeClassesItem.state = ([AKPrefUtils boolValueForPref:AKIncludeClassesAndProtocolsPrefKey]
								 ? NSOnState
								 : NSOffState);
	_includeMethodsItem.state = ([AKPrefUtils boolValueForPref:AKIncludeMethodsPrefKey]
								 ? NSOnState
								 : NSOffState);
	_includeFunctionsAndGlobalsItem.state = ([AKPrefUtils boolValueForPref:AKIncludeFunctionsAndGlobalsPrefKey]
								   ? NSOnState
								   : NSOffState);
	_ignoreCaseItem.state = ([AKPrefUtils boolValueForPref:AKIgnoreCasePrefKey]
							 ? NSOnState
							 : NSOffState);

	// We want everything in the search options popup to be enabled.
	[_searchOptionsPopup setAutoenablesItems:NO];

	// Make extra sure _quicklistTable is properly populated.  (In the
	// case where the user has not set a window-layout pref, it's
	// possible I overlook this step.)
	[self _selectQuicklistMode:_quicklistModeRadio.selectedTag];
}

#pragma mark - Navigation

- (void)searchForString:(NSString *)aString
{
	_searchField.stringValue = aString;
	[self _doSearchUsingStringInSearchField];
}

- (void)includeEverythingInSearch
{
	_includeClassesItem.state = NSOnState;
	_includeMethodsItem.state = NSOnState;
	_includeFunctionsAndGlobalsItem.state = NSOnState;
}

#pragma mark - Action methods

- (IBAction)doQuicklistTableAction:(id)sender
{
	NSInteger selectedRow = _quicklistTable.selectedRow;
	AKDocLocator *selectedDocLocator = ((selectedRow < 0) ? nil : self.docLocators[selectedRow]);

	// If we are in search mode, remember the selected object's position in
	// the search results list, so we can do Find Previous and Find Next.
	if (_selectedQuicklistMode == _AKSearchResultsQuicklistMode) {
		if (selectedRow >= 0) {
			_indexWithinLastSearchResults = selectedRow;
		}
	}

	// Handle the cases where there's nothing to do.
	if (selectedDocLocator == nil) {
		[_removeFavoriteButton setEnabled:NO];
	} else {
		// Update the Favorites-list management buttons.
		_removeFavoriteButton.enabled = (_selectedQuicklistMode == _AKFavoritesQuicklistMode);

		// Tell the main window to navigate to the selected doc.
		[self.owningWindowController selectDocWithDocLocator:selectedDocLocator];
	}
}

- (IBAction)doFrameworkChoiceAction:(id)sender
{
	[self _selectQuicklistMode:-1];  // Forces table to reload.
	[self _selectQuicklistMode:_AKAllClassesInFrameworkQuicklistMode];
}

- (IBAction)removeFavorite:(id)sender
{
	NSInteger row = _quicklistTable.selectedRow;
	if (row >= 0) {
		[[AKAppDelegate appDelegate] removeFavoriteAtIndex:row];
	}
}

- (IBAction)selectSearchField:(id)sender
{
	[self.owningWindowController openQuicklistDrawer];
	[_searchField selectText:nil];
}

- (IBAction)doSearch:(id)sender
{
	[self _doSearchUsingStringInSearchField];
}

- (IBAction)doSearchOptionsPopupAction:(id)sender
{
	NSMenu *searchMenu = _searchOptionsPopup.menu;
	NSInteger indexOfDivider = [searchMenu indexOfItem:_searchOptionsDividerItem];
	NSInteger selectedIndex = _searchOptionsPopup.indexOfSelectedItem;
	NSMenuItem *selectedItem = [sender selectedItem];

	// Was the selected menu item before or after the special menu divider?
	if (selectedIndex < indexOfDivider) {
		// Items before the divider indicate search flags. They are toggled.
		NSInteger oldState = selectedItem.state;
		selectedItem.state = ((oldState == NSOnState) ? NSOffState : NSOnState);
	} else {
		// Items after the divider are previous search strings. Selecting one
		// puts it in the search field.
		_searchField.stringValue = selectedItem.title;
	}

	// Whatever we did changed the search parameters in some way, so re-perform
	// the search.
	[self _doSearchUsingStringInSearchField];
}

#pragma mark - <AKUIConfigurable> methods

- (void)applyUserPreferences
{
	if (_AKFavoritesQuicklistMode == _selectedQuicklistMode) {
		NSArray *favoritesList = [[AKAppDelegate appDelegate] favoritesList];
		if (![favoritesList isEqual:self.docLocators]) {  //TODO: Old note to self says "review".
			[self _reloadQuicklistTable];
		}
	}
	[_quicklistTable applyListFontPrefs];
}

- (void)takeWindowLayoutFrom:(AKWindowLayout *)windowLayout
{
	// Restore the selection in the frameworks popup.
	[_frameworkPopup selectItemWithTitle:windowLayout.frameworkPopupSelection];

	// Restore the settings in the search options popup.
	_includeClassesItem.state = (windowLayout.searchIncludesClasses ? NSOnState : NSOffState);
	_includeMethodsItem.state = (windowLayout.searchIncludesMembers ? NSOnState : NSOffState);
	_includeFunctionsAndGlobalsItem.state = (windowLayout.searchIncludesFunctionsAndGlobals ? NSOnState : NSOffState);
	_ignoreCaseItem.state = (windowLayout.searchIgnoresCase ? NSOnState : NSOffState);

	// Restore the quicklist mode -- after the other ducks have been
	// lined up, so the quicklist table will reload properly.
	[self _selectQuicklistMode:windowLayout.quicklistMode];
}

- (void)putWindowLayoutInto:(AKWindowLayout *)windowLayout
{
	// Remember the quicklist mode.
	windowLayout.quicklistMode = _selectedQuicklistMode;

	// Remember the selection in the frameworks popup.
	windowLayout.frameworkPopupSelection = _frameworkPopup.selectedItem.title;

	// Remember the settings in the search options popup.
	windowLayout.searchIncludesClasses = (_includeClassesItem.state == NSOnState);
	windowLayout.searchIncludesMembers = (_includeMethodsItem.state == NSOnState);
	windowLayout.searchIncludesFunctionsAndGlobals = (_includeFunctionsAndGlobalsItem.state == NSOnState);
	windowLayout.searchIgnoresCase = (_ignoreCaseItem.state == NSOnState);
}

#pragma mark - DIGSFindBufferDelegate methods

- (void)findBufferDidChange:(DIGSFindBuffer *)findBuffer
{
	_searchField.stringValue = findBuffer.findString;
}

#pragma mark - AKMultiRadioViewDelegate methods

- (void)multiRadioViewDidMakeSelection:(AKMultiRadioView *)mrv
{
	[self _selectQuicklistMode:[mrv selectedTag]];
}

#pragma mark - NSUserInterfaceValidations methods

- (BOOL)validateUserInterfaceItem:(id)anItem
{
	SEL itemAction = [anItem action];

	if ((itemAction == @selector(doSearch:))
		|| (itemAction == @selector(doSearchOptionsPopupAction:))
		|| (itemAction == @selector(selectSearchField:)))
	{
		return YES;
	}

	return NO;
}

#pragma mark - NSTableView datasource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return self.docLocators.count;
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(NSInteger)rowIndex
{
	AKDocLocator *docLocator = self.docLocators[rowIndex];
	return docLocator.displayName;
}

#pragma mark - NSTableView delegate methods

- (BOOL)tableView:(NSTableView *)tableView
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(NSInteger)row
	dropOperation:(NSTableViewDropOperation)operation
{
	if (_selectedQuicklistMode != _AKFavoritesQuicklistMode) {
		return NO;
	}
	if (row < 0) {
		return NO;
	}

	NSPasteboard *pboard = [info draggingPasteboard];
	NSArray *draggedRows = (NSArray *)[pboard propertyListForType:_AKQuicklistPasteboardType];
	if (draggedRows.count == 0) {
		return NO;
	}

	int draggedRowIndex = ((NSNumber *)draggedRows[0]).intValue;
	if ((draggedRowIndex < 0) || (draggedRowIndex == row)) {
		return NO;
	}

	[[AKAppDelegate appDelegate] moveFavoriteFromIndex:draggedRowIndex toIndex:row];
	return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(NSInteger)row
	   proposedDropOperation:(NSTableViewDropOperation)operation
{
	if (_selectedQuicklistMode != _AKFavoritesQuicklistMode) {
		return NSDragOperationNone;
	}
	return NSDragOperationGeneric;
}

- (BOOL)tableView:(NSTableView *)tableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
	 toPasteboard:(NSPasteboard*)pboard
{
	if (_selectedQuicklistMode != _AKFavoritesQuicklistMode) {
		return NO;
	}

	NSMutableArray *rows = [[NSMutableArray alloc] init];
	[rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
		[rows addObject:@(idx)];
	}];
	[pboard declareTypes:@[_AKQuicklistPasteboardType] owner:self];
	[pboard setPropertyList:rows forType:_AKQuicklistPasteboardType];
	return YES;
}

#pragma mark - Private methods

- (void)_selectQuicklistMode:(NSInteger)mode
{
	BOOL modeIsChanging = (mode != _selectedQuicklistMode);

	_selectedQuicklistMode = mode;

	// Select the corresponding radio button.
	[_quicklistModeRadio selectCellWithTag:mode];

	// Populate the quicklist table according to whatever quicklist
	// mode is selected.
	if (modeIsChanging) {
		[self _reloadQuicklistTable];
	}
}

- (void)_reloadQuicklistTable
{
	switch (_selectedQuicklistMode) {
		case _AKFavoritesQuicklistMode: {
			NSArray *favoritesList = [[AKAppDelegate appDelegate] favoritesList];
			self.docLocators = [NSArray arrayWithArray:favoritesList];
			break;
		}

		case _AKCollectionClassesQuicklistMode: {
			self.docLocators = [self _collectionClasses];
			break;
		}

		case _AKWindowOrViewControllerClassesQuicklistMode: {
			self.docLocators = [self _windowOrViewControllerClasses];
			break;
		}

		case _AKViewClassesQuicklistMode: {
			self.docLocators = [self _viewClasses];
			break;
		}

		case _AKCellOrLayerClassesQuicklistMode: {
			self.docLocators = [self _cellOrLayerClasses];
			break;
		}

		case _AKClassesWithDelegatesQuicklistMode: {
			self.docLocators = [self _classesWithDelegates];
			break;
		}

		case _AKClassesWithDataSourcesQuicklistMode: {
			self.docLocators = [self _classesWithDataSources];
			break;
		}

		case _AKDataSourceProtocolsQuicklistMode: {
			self.docLocators = [self _dataSourceProtocols];
			break;
		}

		case _AKAllClassesInFrameworkQuicklistMode: {
			self.docLocators = [self _classTokensInFramework:_frameworkPopup.title];
			break;
		}

		case _AKSearchResultsQuicklistMode: {
			self.docLocators = self.lastSearchResults;
			break;
		}

		default: {
			self.docLocators = @[];
			break;
		}
	}

	// Reload the table with the new values.
	[_quicklistTable deselectAll:nil];
	[_quicklistTable reloadData];

	// Since there is no no selection, disable the remove-favorite button.
	[_removeFavoriteButton setEnabled:NO];
}

- (NSArray *)_collectionClasses
{
	static NSArray *s_collectionClasses = nil;
	if (!s_collectionClasses) {
		NSArray *classTokens = [self _sortedDescendantsOfClassesWithNames:@[ @"NSString",
																			 @"NSAttributedString",
																			 @"NSData",
																			 @"NSValue",
																			 @"NSArray",
																			 @"NSDictionary",
																			 @"NSSet",
																			 @"NSDate",
																			 @"NSHashTable",
																			 @"NSMapTable",
																			 @"NSPointerArray"]];
		s_collectionClasses = [self _sortedDocLocatorsForClasses:classTokens];
	}
	return s_collectionClasses;
}

- (NSArray *)_windowOrViewControllerClasses
{
	static NSArray *s_windowOrViewControllerClasses = nil;
	if (!s_windowOrViewControllerClasses) {
#if APPKIDO_FOR_IPHONE
		NSArray *classTokens = [self _sortedDescendantsOfClassesWithNames:@[@"UIViewController"]];
#else
		NSArray *classTokens = [self _sortedDescendantsOfClassesWithNames:@[@"NSWindow"]];
#endif
		s_windowOrViewControllerClasses = [self _sortedDocLocatorsForClasses:classTokens];
	}
	return s_windowOrViewControllerClasses;
}

- (NSArray *)_viewClasses
{
	static NSArray *s_viewClasses = nil;
	if (!s_viewClasses) {
		NSString *nameOfRootViewClass;
		if ([[self.owningWindowController database] classTokenWithName:@"UIView"] != nil) {
			nameOfRootViewClass = @"UIView";
		} else {
			nameOfRootViewClass = @"NSView";
		}
		NSArray *classTokens = [self _sortedDescendantsOfClassesWithNames:@[nameOfRootViewClass]];
		s_viewClasses = [self _sortedDocLocatorsForClasses:classTokens];
	}
	return s_viewClasses;
}

- (NSArray *)_cellOrLayerClasses
{
	static NSArray *s_cellOrLayerClasses = nil;
	if (!s_cellOrLayerClasses) {
#if APPKIDO_FOR_IPHONE
		NSArray *classTokens = [self _sortedDescendantsOfClassesWithNames:@[@"CALayer"]];
#else
		NSArray *classTokens = [self _sortedDescendantsOfClassesWithNames:@[@"NSCell"]];
#endif
		s_cellOrLayerClasses = [self _sortedDocLocatorsForClasses:classTokens];
	}
	return s_cellOrLayerClasses;
}

- (NSArray *)_classesWithDelegates
{
	static NSArray *s_classesWithDelegates = nil;

	if (!s_classesWithDelegates) {
		NSMutableSet *setOfClassTokens = [NSMutableSet set];
		for (AKClassToken *classToken in [[self.owningWindowController database] allClassTokens]) {
			if (classToken.hasDelegate) {
				[setOfClassTokens addObject:classToken];
			}
		}
		NSArray *classTokens = [self _sortedDescendantsOfClassesInSet:setOfClassTokens];
		s_classesWithDelegates = [self _sortedDocLocatorsForClasses:classTokens];
	}

	return s_classesWithDelegates;
}

- (NSArray *)_classesWithDataSources
{
	static NSArray *s_classesWithDataSources = nil;

	if (!s_classesWithDataSources) {
		NSMutableSet *setOfItems = [NSMutableSet set];
		for (AKClassToken *classToken in [[self.owningWindowController database] allClassTokens]) {
			if ([self _classHasDataSource:classToken]) {
				[setOfItems addObject:classToken];
			}
		}
		NSArray *classTokens = [self _sortedDescendantsOfClassesInSet:setOfItems];
		s_classesWithDataSources = [self _sortedDocLocatorsForClasses:classTokens];
	}

	return s_classesWithDataSources;
}

- (BOOL)_classHasDataSource:(AKClassToken *)classToken
{
	// See if the class has a -setDataSource: method.
	if ([classToken instanceMethodWithName:@"setDataSource:"]) {
		return YES;
	}

	// See if the class has a property named "dataSource".
	if ([classToken propertyTokenWithName:@"dataSource"]) {
		return YES;
	}

	// See if there's a protocol named ThisClassDataSource.
	NSString *dataSourceProtocolName = [classToken.name stringByAppendingString:@"DataSource"];
	if ([[self.owningWindowController database] protocolTokenWithName:dataSourceProtocolName]) {
		return YES;
	}

	// We've checked all the ways we can tell if a class has a datasource.
	// If we got this far, we conclude the class has no data source.
	return NO;
}

- (NSArray *)_dataSourceProtocols
{
	static NSArray *s_dataSourceProtocols = nil;
	if (!s_dataSourceProtocols) {
		NSMutableArray *protocolTokens = [NSMutableArray array];
		for (AKProtocolToken *protocolToken in [[self.owningWindowController database] allProtocolTokens]) {
			if ([protocolToken.name ak_contains:@"DataSource"]) {
				[protocolTokens addObject:protocolToken];
			}
		}
		s_dataSourceProtocols = [self _sortedDocLocatorsForProtocols:protocolTokens];
	}
	return s_dataSourceProtocols;
}

- (NSArray *)_classTokensInFramework:(NSString *)fwName
{
	NSArray *classTokens = [[self.owningWindowController database] classTokensInFramework:fwName];
	return [self _sortedDocLocatorsForClasses:classTokens];
}

- (NSArray *)_sortedDocLocatorsForClasses:(NSArray *)classTokens
{
	NSMutableArray *quicklistItems = [NSMutableArray array];
	for (AKClassToken *classToken in classTokens) {
//TODO: Is it safe to assume there is always a doc?
//        // Don't list classes that don't have HTML documentation.  They
//        // may have cropped up in header files and either not been
//        // documented yet or intended for Apple's internal use.
//        if (classToken.tokenDocumentation)
		{
			AKTopic *topic = [[AKClassTopic alloc] initWithClassToken:classToken];
			[quicklistItems addObject:[[AKDocLocator alloc] initWithTopic:topic
															 subtopicName:nil
																  docName:nil]];
		}
	}
	return [quicklistItems ak_sortedBySortName];
}

- (NSArray *)_sortedDocLocatorsForProtocols:(NSArray *)protocolTokens
{
	NSMutableArray *quicklistItems = [NSMutableArray array];

	for (AKProtocolToken *protocolToken in protocolTokens)
	{
//TODO: Is it safe to assume there is always a doc?
//        // Don't list protocols that don't have HTML documentation.  They
//        // may have cropped up in header files and either not been
//        // documented yet or intended for Apple's internal use.
//        if (protocolToken.tokenDocumentation)
		{
			AKTopic *topic = [[AKProtocolTopic alloc] initWithProtocolToken:protocolToken];
			[quicklistItems addObject:[[AKDocLocator alloc] initWithTopic:topic
															 subtopicName:nil
																  docName:nil]];
		}
	}

	return [quicklistItems ak_sortedBySortName];
}

- (NSArray *)_sortedDescendantsOfClassesWithNames:(NSArray *)classNames
{
	NSMutableSet *setOfClassTokens = [NSMutableSet setWithCapacity:100];
	for (NSString *name in classNames) {
		AKClassToken *classToken = [self.owningWindowController.database classTokenWithName:name];
		[setOfClassTokens unionSet:[classToken descendantClassTokens]];
	}
	return [setOfClassTokens ak_sortedBySortName];
}

- (NSArray *)_sortedDescendantsOfClassesInSet:(NSSet *)setOfClassTokens
{
	NSMutableSet *resultSet = [NSMutableSet setWithCapacity:(setOfClassTokens.count * 2)];

	// Add descendant classes of the classes that were found.
	for (AKClassToken *classToken in setOfClassTokens) {
		[resultSet unionSet:[classToken descendantClassTokens]];
	}

	// Sort the classes we found and return the result.
	return [resultSet ak_sortedBySortName];
}

#pragma mark - Private methods - search

// Updates self.lastSearchResults.
- (void)_doSearchUsingStringInSearchField
{
	// Do nothing if no search string was specified.
	NSString *searchString = [_searchField.stringValue ak_trimWhitespace];
	if ((searchString == nil) || [searchString isEqualToString:@""]) {
		_searchField.stringValue = @"";
		return;
	}

	// Make sure the quicklist drawer is open so the user can see the results.
	[self.owningWindowController openQuicklistDrawer];

	// Put the search string at the top of the list of past search strings.
	[_pastSearchStrings removeObject:searchString];
	[_pastSearchStrings insertObject:searchString atIndex:0];

	// Prune the list of past search strings as necessary to keep within limits.
	NSUInteger maxSearchStrings = [AKPrefUtils intValueForPref:AKMaxSearchStringsPrefName];
	while (_pastSearchStrings.count > maxSearchStrings) {
		[_pastSearchStrings removeObjectAtIndex:(_pastSearchStrings.count - 1)];
	}
	[self _updatePastStringsInSearchOptionsPopup];

	// Update the system find-pasteboard.
	[DIGSFindBuffer sharedInstance].findString = searchString;

	// Perform the search.
	self.lastSearchResults = [self _searchResultsWithSearchString:searchString];

	// Change the quicklist mode to search mode.
	[self _selectQuicklistMode:-1];
	[self _selectQuicklistMode:_AKSearchResultsQuicklistMode];

	// If no search results were found, reselect the search field so the user
	// can try again.  Otherwise, select one of the search results.
	if (self.docLocators.count == 0) {
		_indexWithinLastSearchResults = -1;
		[_searchField selectText:nil];
	} else {
		[self _selectSearchResultWithPrefix:searchString];
	}
}

- (NSArray *)_searchResultsWithSearchString:(NSString *)searchString
{
	// Construct a search query that matches the search settings in our UI.
	AKDatabase *database = self.owningWindowController.database;
	AKSearchQuery *searchQuery = [[AKSearchQuery alloc] initWithDatabase:database];
	if ([searchString hasSuffix:@"*"]) {
		searchString = [searchString substringToIndex:(searchString.length - 1)];
		searchQuery.searchComparison = AKSearchForPrefix;
	} else {
		searchQuery.searchComparison = AKSearchForSubstring;
	}
	searchQuery.includesClassesAndProtocols = (_includeClassesItem.state == NSOnState);
	searchQuery.includesMembers = (_includeMethodsItem.state == NSOnState);
	searchQuery.includesFunctionsAndGlobals = (_includeFunctionsAndGlobalsItem.state == NSOnState);
	searchQuery.ignoresCase = (_ignoreCaseItem.state == NSOnState);

	// Perform the search.
	return [searchQuery doSearchForString:searchString];  //TODO: Do search asynchronously.
}

- (void)_selectSearchResultWithPrefix:(NSString *)searchString
{
	NSString *lowercaseSearchString = searchString.lowercaseString;
	NSInteger searchResultIndex = 0;
	NSInteger i;

	for (i = 0; i < self.docLocators.count; i++) {
		AKDocLocator *docLocator = self.docLocators[i];
		if ([docLocator.sortName.lowercaseString hasPrefix:lowercaseSearchString]) {
			searchResultIndex = i;
			break;
		}
	}

	[self _selectSearchResultAtIndex:searchResultIndex];
}

- (void)_selectSearchResultAtIndex:(NSInteger)resultIndex
{
	// Change the quicklist mode to search mode.
	[self _selectQuicklistMode:_AKSearchResultsQuicklistMode];

	// Can't jump if there are no search results.
	if (self.docLocators.count == 0) {
		_indexWithinLastSearchResults = -1;
		return;
	}

	// Reset our remembered index into the array of search results.
	if (resultIndex < 0) {
		resultIndex = self.docLocators.count - 1;
	} else if ((unsigned)resultIndex > self.docLocators.count - 1) {
		resultIndex = 0;
	}
	_indexWithinLastSearchResults = resultIndex;

	// Jump to the search result at the new position.
	[_quicklistTable deselectAll:nil];
	[_quicklistTable scrollRowToVisible:_indexWithinLastSearchResults];
	[_quicklistTable selectRowIndexes:[NSIndexSet indexSetWithIndex:_indexWithinLastSearchResults]
				 byExtendingSelection:NO];

	// Give the quicklist table focus and tell the owning window to navigate to
	// the selected search result.
	(void)[_quicklistTable.window makeFirstResponder:_quicklistTable];
	[_quicklistTable.window makeKeyAndOrderFront:nil];
	[self doQuicklistTableAction:nil];
}

- (void)_updatePastStringsInSearchOptionsPopup
{
	NSMenu *searchMenu = _searchOptionsPopup.menu;
	NSInteger indexOfDivider = [searchMenu indexOfItem:_searchOptionsDividerItem];
	NSInteger numMenuItems = searchMenu.numberOfItems;
	NSInteger i;
	
	// Remove the existing list of past search strings.
	for (i = indexOfDivider + 1; i < numMenuItems; i++) {
		[searchMenu removeItemAtIndex:(indexOfDivider + 1)];
	}
	
	// Add the new list.
	for (NSString *searchString in _pastSearchStrings) {
		[_searchOptionsPopup addItemWithTitle:searchString];
	}
}

@end
