/*
 * AKQuicklistController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKQuicklistController.h"

#import <DIGSFindBuffer.h>

#import "AKFrameworkConstants.h"
#import "AKHTMLConstants.h"
#import "AKPrefUtils.h"
#import "AKSortUtils.h"
#import "AKTextUtils.h"
#import "AKDatabase.h"
#import "AKClassNode.h"
#import "AKProtocolNode.h"
#import "AKMethodNode.h"
#import "AKSearchQuery.h"
#import "AKFileSection.h"
#import "AKAppController.h"
#import "AKWindowController.h"
#import "AKWindowLayout.h"
#import "AKClassTopic.h"
#import "AKProtocolTopic.h"
#import "AKDocLocator.h"
#import "AKTableView.h"
#import "AKMultiRadioView.h"


#pragma mark -
#pragma mark Forward declarations of private methods

@interface AKQuicklistController (Private)

- (void)_selectQuicklistMode:(int)mode;

- (void)_reloadQuicklistTable;

- (NSArray *)_collectionClasses;
- (NSArray *)_windowClasses;
- (NSArray *)_viewClasses;
- (NSArray *)_cellClasses;
- (NSArray *)_classesWithDelegates;
// Getting rid of "Delegate protocols" in Quicklist.
//- (NSArray *)_delegateProtocols;
- (NSArray *)_classesWithDataSources;
- (NSArray *)_dataSourceProtocols;
- (NSArray *)_classesForFramework:(NSString *)frameworkName;

- (NSArray *)_sortedDocLocatorsForClasses:(NSArray *)classNodes;
- (NSArray *)_sortedDocLocatorsForProtocols:(NSArray *)protocolNodes;

- (NSArray *)_sortedDescendantsOfClassesWithNames:(NSArray *)classNames;
- (NSArray *)_sortedDescendantsOfClassesInSet:(NSSet *)nodeSet;

- (void)_jumpToSearchResultAtIndex:(int)index;
- (void)_jumpToSearchResultWithPrefix:(NSString *)searchString;
- (void)_findStringDidChange:(DIGSFindBuffer *)findBuffer;

- (void)_updateSearchOptionsPopup;

- (void)_updateSearchQuery;

@end


#pragma mark -
#pragma mark Private constants

// Pasteboard type used for drag and drop when the quicklist is in
// Favorites mode.
static NSString *_AKQuicklistPasteboardType = @"AKQuicklistPasteboard";

// The following are used as cell tags of the radio buttons used for
// selecting the quicklist mode.
enum
{
    _AKFavoritesQuicklistMode = 0,
    _AKCollectionClassesQuicklistMode = 1,
    _AKWindowClassesQuicklistMode = 2,
    _AKViewClassesQuicklistMode = 3,
    _AKCellClassesQuicklistMode = 4,
    _AKClassesWithDelegatesQuicklistMode = 5,
// Getting rid of "Delegate protocols" in Quicklist.
//    _AKDelegateProtocolsQuicklistMode = 6,
    _AKClassesWithDataSourcesQuicklistMode = 7,
    _AKDataSourceProtocolsQuicklistMode = 8,
    _AKAllClassesInFrameworkQuicklistMode = 9,
    _AKSearchResultsQuicklistMode = 10,
};

@implementation AKQuicklistController


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)init
{
    if ((self = [super init]))
    {
        _currentTableValues = [[NSArray alloc] init];
        _currentQuicklistMode = -1;

        // Initialize search variables.
        _indexWithinSearchResults = -1;
        _searchQuery = nil;  // Wait for -doAwakeFromNib to set this.
        _pastSearchStrings = [[NSMutableArray alloc] init];

        [[DIGSFindBuffer sharedInstance]
            addListener:self
            withSelector:@selector(_findStringDidChange:)];
    }

    return self;
}

- (void)dealloc
{
    [[DIGSFindBuffer sharedInstance] removeListener:self];

    [_currentTableValues release];
    [_searchQuery release];
    [_pastSearchStrings release];

    [super dealloc];
}


#pragma mark -
#pragma mark Window layout

- (void)takeWindowLayoutFrom:(AKWindowLayout *)windowLayout
{
    // Restore the selection in the frameworks popup.
    [_frameworkPopup selectItemWithTitle:[windowLayout frameworkPopupSelection]];

    // Restore the settings in the search options popup.
    [_includeClassesItem setState:([windowLayout searchIncludesClasses] ? NSOnState : NSOffState)];
    [_includeMethodsItem setState:([windowLayout searchIncludesMembers] ? NSOnState : NSOffState)];
    [_includeFunctionsItem setState:([windowLayout searchIncludesFunctions] ? NSOnState : NSOffState)];
    [_includeGlobalsItem setState:([windowLayout searchIncludesGlobals] ? NSOnState : NSOffState)];
    [_ignoreCaseItem setState:([windowLayout searchIgnoresCase] ? NSOnState : NSOffState)];

    // Restore the quicklist mode -- after the other ducks have been
    // lined up, so the quicklist table will reload properly.
    [self _selectQuicklistMode:[windowLayout quicklistMode]];
}

- (void)putWindowLayoutInto:(AKWindowLayout *)windowLayout
{
    // Remember the quicklist mode.
    [windowLayout setQuicklistMode:_currentQuicklistMode];

    // Remember the selection in the frameworks popup.
    [windowLayout setFrameworkPopupSelection:[[_frameworkPopup selectedItem] title]];

    // Remember the settings in the search options popup.
    [windowLayout setSearchIncludesClasses:([_includeClassesItem state] == NSOnState)];
    [windowLayout setSearchIncludesMembers:([_includeMethodsItem state] == NSOnState)];
    [windowLayout setSearchIncludesFunctions:([_includeFunctionsItem state] == NSOnState)];
    [windowLayout setSearchIncludesGlobals:([_includeGlobalsItem state] == NSOnState)];
    [windowLayout setSearchIgnoresCase:([_ignoreCaseItem state] == NSOnState)];
}


#pragma mark -
#pragma mark Navigation

- (void)searchForString:(NSString *)aString
{
    [_searchField setStringValue:aString];
    [self doSearch:self];
}


#pragma mark -
#pragma mark Action methods

- (IBAction)doQuicklistModeMatrixAction:(id)sender
{
    [self _selectQuicklistMode:[sender selectedTag]];
}

- (IBAction)doQuicklistTableAction:(id)sender
{
    int selectedRow = [_quicklistTable selectedRow];
    AKDocLocator *quicklistItem =
        (selectedRow < 0)
        ? nil
        : [_currentTableValues objectAtIndex:selectedRow];

    // If we are in search mode, remember the selected object's position in
    // the search results list, so we can do Find Previous and Find Next.
    if (_currentQuicklistMode == _AKSearchResultsQuicklistMode)
    {
        if (selectedRow >= 0)
        {
            _indexWithinSearchResults = selectedRow;
        }
    }

    // Handle the cases where there's nothing to do.
    if (quicklistItem == nil)
    {
        [_removeFavoriteButton setEnabled:NO];
    }
    else
    {
        // Update the Favorites-list management buttons.
        [_removeFavoriteButton setEnabled:(_currentQuicklistMode == _AKFavoritesQuicklistMode)];

        // Tell the main window to navigate to the selected doc.
        [_windowController jumpToDocLocator:quicklistItem];
    }
}

- (IBAction)doFrameworkChoiceAction:(id)sender
{
    [self _selectQuicklistMode:-1];  // force reload
    [self _selectQuicklistMode:_AKAllClassesInFrameworkQuicklistMode];
}

- (IBAction)removeFavorite:(id)sender
{
    int row = [_quicklistTable selectedRow];

    if (row >= 0)
    {
        AKAppController *appController = [NSApp delegate];

        [appController removeFavoriteAtIndex:row];
    }
}

- (IBAction)selectSearchField:(id)sender
{
    [_searchField selectText:nil];
}

- (IBAction)doSearch:(id)sender
{
    NSString *searchString = [[_searchField stringValue] ak_trimWhitespace];

    // Do nothing if no search string was specified.
    if ((searchString == nil) || [searchString isEqualToString:@""])
    {
        return;
    }

    // Update the list of past search strings with the current string.
    [_pastSearchStrings removeObject:searchString];
    [_pastSearchStrings insertObject:searchString atIndex:0];

    int maxSearchStrings = [AKPrefUtils intValueForPref:AKMaxSearchStringsPrefName];

    while ((int)[_pastSearchStrings count] > maxSearchStrings)
    {
        [_pastSearchStrings removeObjectAtIndex:([_pastSearchStrings count] - 1)];
    }

    [self _updateSearchOptionsPopup];

    // Update the system find-pasteboard.
    [[DIGSFindBuffer sharedInstance] setFindString:searchString];

    // Update the search query.
    [self _updateSearchQuery];

    // This will clear the quicklist table and thus force it to reload
    // When we select Search Results mode.
    [self _selectQuicklistMode:-1];

    // Change the quicklist mode to search mode.
    [self _selectQuicklistMode:_AKSearchResultsQuicklistMode];

    // If no search results were found, reselect the search field so the
    // user can try again.  Otherwise, select the first search result.
    NSArray *searchResults = [_searchQuery queryResults];
    int numSearchResults = [searchResults count];
    if (numSearchResults == 0)
    {
        _indexWithinSearchResults = -1;
        [_searchField selectText:nil];
    }
    else
    {
        [self _jumpToSearchResultWithPrefix:searchString];
    }
}

- (IBAction)doSearchOptionsPopupAction:(id)sender
{
    NSMenu *searchMenu = [_searchOptionsPopup menu];
    int indexOfDivider = [searchMenu indexOfItem:_searchOptionsDividerItem];
    int selectedIndex = [_searchOptionsPopup indexOfSelectedItem];
    NSMenuItem *selectedItem = [sender selectedItem];

    if (selectedIndex < indexOfDivider)
    {
        int oldState = [selectedItem state];

        [selectedItem
            setState:((oldState == NSOnState) ? NSOffState : NSOnState)];
    }
    else
    {
        [_searchField setStringValue:[selectedItem title]];
    }

    [self doSearch:sender];
}

- (IBAction)selectPreviousSearchResult:(id)sender
{
    if (![[_searchField stringValue]
        isEqualToString:[_searchQuery searchString]])
    {
        [self doSearch:nil];
        return;
    }

    [self _jumpToSearchResultAtIndex:(_indexWithinSearchResults - 1)];
}

- (IBAction)selectNextSearchResult:(id)sender
{
    if (![[_searchField stringValue]
        isEqualToString:[_searchQuery searchString]])
    {
        [self doSearch:nil];
        return;
    }

    [self _jumpToSearchResultAtIndex:(_indexWithinSearchResults + 1)];
}


#pragma mark -
#pragma mark AKSubcontroller methods

- (void)doAwakeFromNib
{
    // Set our _searchQuery ivar.  We do it here instead of in -init
    // because we need to be sure [_windowController database] has been set.
    _searchQuery =
        [[AKSearchQuery alloc]
            initWithDatabase:[_windowController database]];

    // Set up _quicklistTable to do drag and drop.
    [_quicklistTable registerForDraggedTypes:
        [NSArray arrayWithObject:_AKQuicklistPasteboardType]];

    // Set up the popup menu of frameworks for the "Classes in framework:"
    // quicklist item.
    // Note that the IB default for popup buttons is to autoenable items.
    // We don't want that.
    [_frameworkPopup setAutoenablesItems:NO];

    NSEnumerator *fwEnum =
        [[[_windowController database] sortedFrameworkNames] objectEnumerator];
    NSString *fwName;

    while ((fwName = [fwEnum nextObject]))
    {
        [_frameworkPopup addItemWithTitle:fwName];
    }

    // Initialize the search field to match the system find-pasteboard.
    [_searchField setStringValue:
        [[DIGSFindBuffer sharedInstance] findString]];

    // Match the search options popup to the user's preferences.
    [_includeClassesItem setState:
        ([AKPrefUtils
            boolValueForPref:AKIncludeClassesAndProtocolsPrefKey]
        ? NSOnState
        : NSOffState)];
    [_includeMethodsItem setState:
        ([AKPrefUtils boolValueForPref:AKIncludeMethodsPrefKey]
        ? NSOnState
        : NSOffState)];
    [_includeFunctionsItem setState:
        ([AKPrefUtils boolValueForPref:AKIncludeFunctionsPrefKey]
        ? NSOnState
        : NSOffState)];
    [_includeGlobalsItem setState:
        ([AKPrefUtils
            boolValueForPref:AKIncludeGlobalsPrefKey]
        ? NSOnState
        : NSOffState)];
    [_ignoreCaseItem setState:
        ([AKPrefUtils
            boolValueForPref:AKIgnoreCasePrefKey]
        ? NSOnState
        : NSOffState)];

    // We want everything in the search options popup to be enabled.
    [_searchOptionsPopup setAutoenablesItems:NO];

    // Make extra sure _quicklistTable is properly populated.  (In the
    // case where the user has not set a window-layout pref, it's
    // possible I overlook this step.)
    [self _selectQuicklistMode:[_quicklistModeRadio selectedTag]];
}

- (void)applyUserPreferences
{
    if (_AKFavoritesQuicklistMode == _currentQuicklistMode)
    {
        AKAppController *appController = [NSApp delegate];
        NSArray *favoritesList = [appController favoritesList];

        if (![favoritesList isEqual:_currentTableValues])
        {
            [self _reloadQuicklistTable];
        }
    }

    [_quicklistTable applyListFontPrefs];
}

- (BOOL)validateItem:(id)anItem
{
    SEL itemAction = [anItem action];

    if ((itemAction == @selector(doSearch:))
        || (itemAction == @selector(doSearchOptionsPopupAction:))
        || (itemAction == @selector(selectSearchField:)))
    {
        return YES;
    }
    else if ((itemAction == @selector(selectPreviousSearchResult:))
        || (itemAction == @selector(selectNextSearchResult:)))
    {
        return
            (([[_searchQuery queryResults] count] > 0)
            || ([[_searchQuery searchString] length] > 0));
    }

    return NO;
}


#pragma mark -
#pragma mark NSTableView datasource methods

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_currentTableValues count];
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
    AKDocLocator *quicklistItem =
        [_currentTableValues objectAtIndex:rowIndex];

    return [quicklistItem stringToDisplayInLists];
}


#pragma mark -
#pragma mark NSTableView delegate methods

- (BOOL)tableView:(NSTableView*)tableView
    acceptDrop:(id <NSDraggingInfo>)info
    row:(int)row
    dropOperation:(NSTableViewDropOperation)operation
{
    if (_currentQuicklistMode != _AKFavoritesQuicklistMode)
    {
        return NO;
    }

    if (row < 0)
    {
        return NO;
    }

    NSPasteboard *pboard = [info draggingPasteboard];
    NSArray *draggedRows =
        (NSArray *)[pboard propertyListForType:_AKQuicklistPasteboardType];

    if ([draggedRows count] == 0)
    {
        return NO;
    }

    int draggedRowIndex =
        [(NSNumber *)[draggedRows objectAtIndex:0] intValue];

    if ((draggedRowIndex < 0) || (draggedRowIndex == row))
    {
        return NO;
    }

    AKAppController *appController = [NSApp delegate];

    [appController
        moveFavoriteFromIndex:draggedRowIndex
        toIndex:row];

    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tableView
    validateDrop:(id <NSDraggingInfo>)info
    proposedRow:(int)row
    proposedDropOperation:(NSTableViewDropOperation)operation
{
    if (_currentQuicklistMode != _AKFavoritesQuicklistMode)
    {
        return NSDragOperationNone;
    }

    return operation;
}

- (BOOL)tableView:(NSTableView *)tableView
    writeRows:(NSArray*)rows
    toPasteboard:(NSPasteboard*)pboard
{
    if (_currentQuicklistMode != _AKFavoritesQuicklistMode)
    {
        return NO;
    }

    [pboard
        declareTypes:
            [NSArray arrayWithObjects:
                _AKQuicklistPasteboardType,
                nil]
        owner:self];
    [pboard
        setPropertyList:rows
        forType:_AKQuicklistPasteboardType];

    return YES;
}

@end


#pragma mark -
#pragma mark Private methods

@implementation AKQuicklistController (Private)

- (void)_selectQuicklistMode:(int)mode
{
    BOOL modeIsChanging = (mode != _currentQuicklistMode);

    _currentQuicklistMode = mode;

    // Select the corresponding radio button.
    [_quicklistModeRadio selectCellWithTag:mode];

    // Populate the quicklist table according to whatever quicklist
    // mode is selected.
    if (modeIsChanging)
    {
        [self _reloadQuicklistTable];
    }
}

- (void)_reloadQuicklistTable
{
    NSArray *tableValues = nil;

    switch (_currentQuicklistMode)
    {
        case _AKFavoritesQuicklistMode:
        {
            AKAppController *appController = [NSApp delegate];
            NSArray *favoritesList = [appController favoritesList];

            tableValues = [NSArray arrayWithArray:favoritesList];
            break;
        }

        case _AKCollectionClassesQuicklistMode:
        {
            tableValues = [self _collectionClasses];
            break;
        }

        case _AKWindowClassesQuicklistMode:
        {
            tableValues = [self _windowClasses];
            break;
        }

        case _AKViewClassesQuicklistMode:
        {
            tableValues = [self _viewClasses];
            break;
        }

        case _AKCellClassesQuicklistMode:
        {
            tableValues = [self _cellClasses];
            break;
        }

        case _AKClassesWithDelegatesQuicklistMode:
        {
            tableValues = [self _classesWithDelegates];
            break;
        }

// Getting rid of "Delegate protocols" in Quicklist.
//        case _AKDelegateProtocolsQuicklistMode:
//        {
//            tableValues = [self _delegateProtocols];
//            break;
//        }

        case _AKClassesWithDataSourcesQuicklistMode:
        {
            tableValues = [self _classesWithDataSources];
            break;
        }

        case _AKDataSourceProtocolsQuicklistMode:
        {
            tableValues = [self _dataSourceProtocols];
            break;
        }

        case _AKAllClassesInFrameworkQuicklistMode:
        {
            NSString *frameworkName = [_frameworkPopup title];

            tableValues = [self _classesForFramework:frameworkName];
            break;
        }

        case _AKSearchResultsQuicklistMode:
        {
            [self _updateSearchQuery];
            tableValues = [_searchQuery queryResults];
            break;
        }

        default:
        {
            tableValues = [NSArray array];
            break;
        }
    }

    // Make the transition to the newly computed table values, using the
    // standard setter pattern.
    [tableValues retain];
    [_currentTableValues release];
    _currentTableValues = tableValues;

    // Reload the table with the new values.
    [_quicklistTable deselectAll:nil];
    [_quicklistTable reloadData];

    // Since there is no no selection, disable the remove-favorite button.
    [_removeFavoriteButton setEnabled:NO];
}

- (NSArray *)_collectionClasses
{
    static NSArray *s_collectionClasses = nil;

    if (!s_collectionClasses)
    {
        NSArray *arr =
            [NSArray arrayWithObjects:
                @"NSString",
                @"NSAttributedString",
                @"NSData",
                @"NSValue",
                @"NSArray",
                @"NSDictionary",
                @"NSSet",
                nil];
        NSArray *classNodes = [self _sortedDescendantsOfClassesWithNames:arr];

        s_collectionClasses =
            [[self _sortedDocLocatorsForClasses:classNodes] retain];
    }

    return s_collectionClasses;
}

- (NSArray *)_windowClasses
{
    static NSArray *s_windowClasses = nil;

    if (!s_windowClasses)
    {
        NSArray *arr = [NSArray arrayWithObjects:@"NSWindow", nil];
        NSArray *classNodes = [self _sortedDescendantsOfClassesWithNames:arr];

        s_windowClasses =
            [[self _sortedDocLocatorsForClasses:classNodes] retain];
    }

    return s_windowClasses;
}

- (NSArray *)_viewClasses
{
    static NSArray *s_viewClasses = nil;

    if (!s_viewClasses)
    {
        NSString *nameOfRootViewClass;

        if ([[_windowController database] classWithName:@"UIView"] != nil)
        {
            nameOfRootViewClass = @"UIView";
        }
        else
        {
            nameOfRootViewClass = @"NSView";
        }

        NSArray *arr = [NSArray arrayWithObjects:nameOfRootViewClass, nil];
        NSArray *classNodes = [self _sortedDescendantsOfClassesWithNames:arr];

        s_viewClasses =
            [[self _sortedDocLocatorsForClasses:classNodes] retain];
    }

    return s_viewClasses;
}

- (NSArray *)_cellClasses
{
    static NSArray *s_cellClasses = nil;

    if (!s_cellClasses)
    {
        NSArray *arr = [NSArray arrayWithObjects:@"NSCell", nil];
        NSArray *classNodes = [self _sortedDescendantsOfClassesWithNames:arr];

        s_cellClasses =
            [[self _sortedDocLocatorsForClasses:classNodes] retain];
    }

    return s_cellClasses;
}

- (NSArray *)_classesWithDelegates
{
    static NSArray *s_classesWithDelegates = nil;

    if (!s_classesWithDelegates)
    {
        NSMutableSet *nodeSet = [NSMutableSet set];
        NSArray *classNodes = [[_windowController database] allClasses];
        NSEnumerator *en = [classNodes objectEnumerator];
        AKClassNode *classNode;

        while ((classNode = [en nextObject]))
        {
            BOOL classHasDelegate = NO;

            // See if the class doc contains a "Delegate Methods" section.
            AKFileSection *delegateMethodsSection =
                [[classNode nodeDocumentation]
                    childSectionWithName:
                        AKDelegateMethodsHTMLSectionName];

            if (!delegateMethodsSection)
            {
                delegateMethodsSection =
                    [[classNode nodeDocumentation]
                        childSectionWithName:
                            AKDelegateMethodsAlternateHTMLSectionName];
            }

            if (delegateMethodsSection)
            {
                classHasDelegate = YES;
            }

            // If not, see if the class has a method with a name like setFooDelegate:.
            if (!classHasDelegate)
            {
                NSEnumerator *methodEnum =
                    [[classNode documentedInstanceMethods]
                        objectEnumerator];
                AKMethodNode *methodNode;

                while ((methodNode = [methodEnum nextObject]))
                {
                    NSString *methodName = [methodNode nodeName];

                    if ([methodName hasPrefix:@"set"]
                        && [methodName hasSuffix:@"Delegate:"])
                    {
                        classHasDelegate = YES;
                        break;
                    }
                }
            }

            // If not, see if the class has a property named "delegate" or "fooDelegate".
            if (!classHasDelegate)
            {
                NSEnumerator *propertyEnum =
                    [[classNode documentedProperties]
                        objectEnumerator];
                AKPropertyNode *propertyNode;

                while ((propertyNode = [propertyEnum nextObject]))
                {
                    NSString *propertyName = [propertyNode nodeName];

                    if ([propertyName isEqual:@"delegate"]
                        || [propertyName hasSuffix:@"Delegate:"])
                    {
                        classHasDelegate = YES;
                        break;
                    }
                }
            }

            // If not, see if there's a protocol named thisClassDelegate.
            NSString *possibleDelegateProtocolName =
                [[classNode nodeName] stringByAppendingString:@"Delegate"];
            if ([[_windowController database] protocolWithName:possibleDelegateProtocolName])
            {
                classHasDelegate = YES;
            }

            // We've checked all the ways we can tell if a class has a delegate.
            if (classHasDelegate)
            {
                [nodeSet addObject:classNode];
            }
        }

        classNodes = [self _sortedDescendantsOfClassesInSet:nodeSet];
        s_classesWithDelegates =
            [[self _sortedDocLocatorsForClasses:classNodes] retain];
    }

    return s_classesWithDelegates;
}

- (NSArray *)_classesWithDataSources
{
    static NSArray *s_classesWithDataSources = nil;

    if (!s_classesWithDataSources)
    {
        NSMutableSet *nodeSet = [NSMutableSet set];
        NSArray *classNodes = [[_windowController database] allClasses];
        NSEnumerator *en = [classNodes objectEnumerator];
        AKClassNode *classNode;

        while ((classNode = [en nextObject]))
        {
            BOOL classHasDataSource = NO;

            // See if the class has a -setDataSource: method.
            NSEnumerator *methodEnum =
                [[classNode documentedInstanceMethods]
                    objectEnumerator];
            AKMethodNode *methodNode;

            while ((methodNode = [methodEnum nextObject]))
            {
                NSString *methodName = [methodNode nodeName];

                if ([methodName isEqualToString:@"setDataSource:"])
                {
                    classHasDataSource = YES;
                    break;
                }
            }

            // If not, see if the class has a property named "dataSource".
            if (!classHasDataSource)
            {
                NSEnumerator *propertyEnum =
                    [[classNode documentedProperties]
                        objectEnumerator];
                AKPropertyNode *propertyNode;

                while ((propertyNode = [propertyEnum nextObject]))
                {
                    NSString *propertyName = [propertyNode nodeName];

                    if ([propertyName isEqual:@"dataSource"])
                    {
                        classHasDataSource = YES;
                        break;
                    }
                }
            }

            // If not, see if there's a protocol named thisClassDataSource.
            NSString *possibleDataSourceProtocolName =
                [[classNode nodeName] stringByAppendingString:@"DataSource"];
            if ([[_windowController database] protocolWithName:possibleDataSourceProtocolName])
            {
                classHasDataSource = YES;
            }

            // We've checked all the ways we can tell if a class has a datasource.
            if (classHasDataSource)
            {
                [nodeSet addObject:classNode];
            }
        }

        classNodes = [self _sortedDescendantsOfClassesInSet:nodeSet];
        s_classesWithDataSources =
            [[self _sortedDocLocatorsForClasses:classNodes] retain];
    }

    return s_classesWithDataSources;
}

- (NSArray *)_dataSourceProtocols
{
    static NSArray *s_dataSourceProtocols = nil;

    if (!s_dataSourceProtocols)
    {
        NSEnumerator *en =
            [[[_windowController database] allProtocols]
                objectEnumerator];
        AKProtocolNode *protocolNode;
        NSMutableArray *protocolNodes = [NSMutableArray array];

        while ((protocolNode = [en nextObject]))
        {
            if ([[protocolNode nodeName] ak_contains:@"DataSource"])
            {
                [protocolNodes addObject:protocolNode];
            }
        }

        s_dataSourceProtocols =
            [[self _sortedDocLocatorsForProtocols:protocolNodes] retain];
    }

    return s_dataSourceProtocols;
}

- (NSArray *)_classesForFramework:(NSString *)fwName
{
    NSArray *classNodes =
        [[_windowController database] classesForFrameworkNamed:fwName];

    return [self _sortedDocLocatorsForClasses:classNodes];
}

- (NSArray *)_sortedDocLocatorsForClasses:(NSArray *)classNodes
{
    NSMutableArray *quicklistItems = [NSMutableArray array];
    NSEnumerator *en = [classNodes objectEnumerator];
    AKClassNode *classNode;

    while ((classNode = [en nextObject]))
    {
        // Don't list classes that don't have HTML documentation.  They
        // may have cropped up in header files and either not been
        // documented yet or intended for Apple's internal use.
        if ([classNode nodeDocumentation])
        {
            AKTopic *topic = [AKClassTopic topicWithClassNode:classNode];

            [quicklistItems addObject:[AKDocLocator withTopic:topic subtopicName:nil docName:nil]];
        }
    }

    return [AKSortUtils arrayBySortingArray:quicklistItems];
}

- (NSArray *)_sortedDocLocatorsForProtocols:(NSArray *)protocolNodes
{
    NSMutableArray *quicklistItems = [NSMutableArray array];
    NSEnumerator *en = [protocolNodes objectEnumerator];
    AKProtocolNode *protocolNode;

    while ((protocolNode = [en nextObject]))
    {
        // Don't list protocols that don't have HTML documentation.  They
        // may have cropped up in header files and either not been
        // documented yet or intended for Apple's internal use.
        if ([protocolNode nodeDocumentation])
        {
            AKTopic *topic = [AKProtocolTopic topicWithProtocolNode:protocolNode];

            [quicklistItems addObject:[AKDocLocator withTopic:topic subtopicName:nil docName:nil]];
        }
    }

    return [AKSortUtils arrayBySortingArray:quicklistItems];
}

- (NSArray *)_sortedDescendantsOfClassesWithNames:(NSArray *)classNames
{
    NSMutableSet *nodeSet = [NSMutableSet setWithCapacity:100];
    AKDatabase *db = [_windowController database];
    NSEnumerator *en = [classNames objectEnumerator];
    NSString *name;

    while ((name = [en nextObject]))
    {
        AKClassNode *classNode = [db classWithName:name];

        [nodeSet unionSet:[classNode descendantClasses]];
    }

    return [AKSortUtils arrayBySortingSet:nodeSet];
}

- (NSArray *)_sortedDescendantsOfClassesInSet:(NSSet *)nodeSet
{
    NSMutableSet *resultSet = [NSMutableSet setWithCapacity:([nodeSet count] * 2)];
    NSEnumerator *en = [nodeSet objectEnumerator];
    AKClassNode *node;

    // Add descendant classes of the classes that were found.
    while ((node = [en nextObject]))
    {
        [resultSet unionSet:[node descendantClasses]];
    }

    // Sort the classes we found and return the result.
    return [AKSortUtils arrayBySortingSet:resultSet];
}

- (void)_jumpToSearchResultAtIndex:(int)index
{
    // Change the quicklist mode to search mode.
    [self _selectQuicklistMode:_AKSearchResultsQuicklistMode];

    // Can't jump if there are no search results.
    if ([[_searchQuery queryResults] count] == 0)
    {
        _indexWithinSearchResults = -1;
        return;
    }

    // Reset our remembered index into the array of search results.
    if (index < 0)
    {
        index = [[_searchQuery queryResults] count] - 1;
    }
    else if ((unsigned)index > [[_searchQuery queryResults] count] - 1)
    {
        index = 0;
    }
    _indexWithinSearchResults = index;

    // Jump to the search result at the new position.
    [_quicklistTable deselectAll:nil];
    [_quicklistTable scrollRowToVisible:_indexWithinSearchResults];
    [_quicklistTable selectRow:_indexWithinSearchResults byExtendingSelection:NO];

    // Give the quicklist table focus and tell the owning window to navigate to the selected search result.
    (void)[[_quicklistTable window] makeFirstResponder:_quicklistTable];
    [[_quicklistTable window] makeKeyAndOrderFront:nil];
    [self doQuicklistTableAction:nil];
}

- (void)_jumpToSearchResultWithPrefix:(NSString *)searchString
{
    int searchResultIndex = 0;
    NSArray *searchResults = [_searchQuery queryResults];
    int numSearchResults = [searchResults count];
    int i;

    for (i = 0; i < numSearchResults; i++)
    {
        AKDocLocator *docLocator = [searchResults objectAtIndex:i];

        if ([[docLocator docName] hasPrefix:searchString])
        {
            searchResultIndex = i;
            break;
        }
    }

    [self _jumpToSearchResultAtIndex:searchResultIndex];
}

- (void)_findStringDidChange:(DIGSFindBuffer *)findBuffer
{
    [_searchField setStringValue:[findBuffer findString]];
    [_searchField selectText:nil];
}

- (void)_updateSearchOptionsPopup
{
    NSMenu *searchMenu = [_searchOptionsPopup menu];
    int indexOfDivider = [searchMenu indexOfItem:_searchOptionsDividerItem];
    int numMenuItems = [searchMenu numberOfItems];
    int i;

    // Remove the existing list of past search strings.
    for (i = indexOfDivider + 1; i < numMenuItems; i++)
    {
        [searchMenu removeItemAtIndex:(indexOfDivider + 1)];
    }

    // Add the new list.
    NSEnumerator *stringEnum = [_pastSearchStrings objectEnumerator];
    NSString *searchString;

    while ((searchString = [stringEnum nextObject]))
    {
        [_searchOptionsPopup addItemWithTitle:searchString];
    }
}

- (void)_updateSearchQuery
{
    NSString *searchString = [[_searchField stringValue] ak_trimWhitespace];

    if ([searchString hasSuffix:@"*"])
    {
        [_searchQuery setSearchString:[searchString substringToIndex:([searchString length] - 1)]];
        [_searchQuery setSearchComparison:AKSearchForPrefix];
    }
    else
    {
        [_searchQuery setSearchString:searchString];
        [_searchQuery setSearchComparison:AKSearchForSubstring];
    }

    [_searchQuery setIncludesClassesAndProtocols:([_includeClassesItem state] == NSOnState)];
    [_searchQuery setIncludesMembers:([_includeMethodsItem state] == NSOnState)];
    [_searchQuery setIncludesFunctions:([_includeFunctionsItem state] == NSOnState)];
    [_searchQuery setIncludesGlobals:([_includeGlobalsItem state] == NSOnState)];
    [_searchQuery setIgnoresCase:([_ignoreCaseItem state] == NSOnState)];
}

@end
