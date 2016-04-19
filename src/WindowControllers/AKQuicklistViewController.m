/*
 * AKQuicklistViewController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKQuicklistViewController.h"

#import "DIGSLog.h"
#import "DIGSFindBuffer.h"

#import "AKAppDelegate.h"
#import "AKClassNode.h"
#import "AKClassTopic.h"
#import "AKDatabase.h"
#import "AKDocLocator.h"
#import "AKFileSection.h"
#import "AKFrameworkConstants.h"
#import "AKHTMLConstants.h"
#import "AKMethodNode.h"
#import "AKMultiRadioView.h"
#import "AKPrefUtils.h"
#import "AKPropertyNode.h"
#import "AKProtocolNode.h"
#import "AKProtocolTopic.h"
#import "AKSearchQuery.h"
#import "AKSortUtils.h"
#import "AKTableView.h"
#import "AKWindowController.h"
#import "AKWindowLayout.h"

#import "NSString+AppKiDo.h"

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
@property (nonatomic, strong) NSArray *docLocators;
@end

@implementation AKQuicklistViewController

@synthesize docLocators = _docLocators;

@synthesize quicklistModeRadio = _quicklistModeRadio;
@synthesize quicklistRadio1 = _quicklistRadio1;
@synthesize quicklistRadio2 = _quicklistRadio2;
@synthesize quicklistRadio3 = _quicklistRadio3;
@synthesize frameworkPopup = _frameworkPopup;
@synthesize searchField = _searchField;
@synthesize searchOptionsPopup = _searchOptionsPopup;
@synthesize includeClassesItem = _includeClassesItem;
@synthesize includeMethodsItem = _includeMethodsItem;
@synthesize includeFunctionsItem = _includeFunctionsItem;
@synthesize includeGlobalsItem = _includeGlobalsItem;
@synthesize ignoreCaseItem = _ignoreCaseItem;
@synthesize searchOptionsDividerItem = _searchOptionsDividerItem;
@synthesize quicklistTable = _quicklistTable;
@synthesize removeFavoriteButton = _removeFavoriteButton;

#pragma mark -
#pragma mark Init/dealloc/awake

- (id)initWithNibName:nibName windowController:(AKWindowController *)windowController
{
    self = [super initWithNibName:@"QuicklistView" windowController:windowController];
    if (self)
    {
        _docLocators = [[NSArray alloc] init];
        _selectedQuicklistMode = -1;

        _indexWithinSearchResults = -1;
        _searchQuery = [[AKSearchQuery alloc] initWithDatabase:[windowController database]];
        _pastSearchStrings = [[NSMutableArray alloc] init];

        [[DIGSFindBuffer sharedInstance] addDelegate:self];
    }

    return self;
}

- (id)initWithDefaultNib
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
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

    for (NSString *fwName in [[[self owningWindowController] database] sortedFrameworkNames])
    {
        [_frameworkPopup addItemWithTitle:fwName];
    }

    // Initialize the search field to match the system find-pasteboard.
    [_searchField setStringValue:[[DIGSFindBuffer sharedInstance] findString]];

    // Match the search options popup to the user's preferences.
    [_includeClassesItem setState:([AKPrefUtils boolValueForPref:AKIncludeClassesAndProtocolsPrefKey]
                                   ? NSOnState
                                   : NSOffState)];
    [_includeMethodsItem setState:([AKPrefUtils boolValueForPref:AKIncludeMethodsPrefKey]
                                   ? NSOnState
                                   : NSOffState)];
    [_includeFunctionsItem setState:([AKPrefUtils boolValueForPref:AKIncludeFunctionsPrefKey]
                                     ? NSOnState
                                     : NSOffState)];
    [_includeGlobalsItem setState:([AKPrefUtils boolValueForPref:AKIncludeGlobalsPrefKey]
                                   ? NSOnState
                                   : NSOffState)];
    [_ignoreCaseItem setState:([AKPrefUtils boolValueForPref:AKIgnoreCasePrefKey]
                               ? NSOnState
                               : NSOffState)];

    // We want everything in the search options popup to be enabled.
    [_searchOptionsPopup setAutoenablesItems:NO];

    // Make extra sure _quicklistTable is properly populated.  (In the
    // case where the user has not set a window-layout pref, it's
    // possible I overlook this step.)
    [self _selectQuicklistMode:[_quicklistModeRadio selectedTag]];
}

#pragma mark -
#pragma mark Navigation

- (void)searchForString:(NSString *)aString
{
    [_searchField setStringValue:aString];
    [self doSearch:self];
}

- (void)includeEverythingInSearch
{
    [_includeClassesItem setState:NSOnState];
    [_includeMethodsItem setState:NSOnState];
    [_includeFunctionsItem setState:NSOnState];
    [_includeGlobalsItem setState:NSOnState];

    [self _updateSearchQuery];
}

#pragma mark -
#pragma mark Action methods

- (IBAction)doQuicklistTableAction:(id)sender
{
    NSInteger selectedRow = [_quicklistTable selectedRow];
    AKDocLocator *selectedDocLocator = ((selectedRow < 0)
                                        ? nil
                                        : [_docLocators objectAtIndex:selectedRow]);

    // If we are in search mode, remember the selected object's position in
    // the search results list, so we can do Find Previous and Find Next.
    if (_selectedQuicklistMode == _AKSearchResultsQuicklistMode)
    {
        if (selectedRow >= 0)
        {
            _indexWithinSearchResults = selectedRow;
        }
    }

    // Handle the cases where there's nothing to do.
    if (selectedDocLocator == nil)
    {
        [_removeFavoriteButton setEnabled:NO];
    }
    else
    {
        // Update the Favorites-list management buttons.
        [_removeFavoriteButton setEnabled:(_selectedQuicklistMode == _AKFavoritesQuicklistMode)];

        // Tell the main window to navigate to the selected doc.
        [[self owningWindowController] selectDocWithDocLocator:selectedDocLocator];
    }
}

- (IBAction)doFrameworkChoiceAction:(id)sender
{
    [self _selectQuicklistMode:-1];  // Forces table to reload.
    [self _selectQuicklistMode:_AKAllClassesInFrameworkQuicklistMode];
}

- (IBAction)removeFavorite:(id)sender
{
    NSInteger row = [_quicklistTable selectedRow];

    if (row >= 0)
    {
        [[AKAppDelegate appDelegate] removeFavoriteAtIndex:row];
    }
}

- (IBAction)selectSearchField:(id)sender
{
    [[self owningWindowController] openQuicklistDrawer];
    [_searchField selectText:nil];
}

- (IBAction)doSearch:(id)sender
{
    // Do nothing if no search string was specified.
    NSString *searchString = [[_searchField stringValue] ak_trimWhitespace];
    if ((searchString == nil) || [searchString isEqualToString:@""])
    {
        [_searchField setStringValue:@""];
        return;
    }

    // Make sure the quicklist drawer is open so the user can see the results.
    [[self owningWindowController] openQuicklistDrawer];

    // Put the search string at the top of the list of past search strings.
//ARC    [[searchString retain] autorelease];  // Avoid premature dealloc.
    [_pastSearchStrings removeObject:searchString];
    [_pastSearchStrings insertObject:searchString atIndex:0];

    // Prune the list of past search strings as necessary to keep within limits.
    NSInteger maxSearchStrings = [AKPrefUtils intValueForPref:AKMaxSearchStringsPrefName];

    while ((int)[_pastSearchStrings count] > maxSearchStrings)
    {
        [_pastSearchStrings removeObjectAtIndex:([_pastSearchStrings count] - 1)];
    }

    [self _updatePastStringsInSearchOptionsPopup];

    // Update the system find-pasteboard.
    [[DIGSFindBuffer sharedInstance] setFindString:searchString];

    // Update the search query to use the (possibly new) search string.
    [self _updateSearchQuery];

    // Change the quicklist mode to search mode.
    [self _selectQuicklistMode:-1];  // Forces table to reload.
    [self _selectQuicklistMode:_AKSearchResultsQuicklistMode];

    // If no search results were found, reselect the search field so the
    // user can try again.  Otherwise, select the first search result.
    NSArray *searchResults = [_searchQuery queryResults];
    NSInteger numSearchResults = [searchResults count];
    if (numSearchResults == 0)
    {
        _indexWithinSearchResults = -1;
        [_searchField selectText:nil];
    }
    else
    {
        [self _selectSearchResultWithPrefix:searchString];
    }
}

- (IBAction)doSearchOptionsPopupAction:(id)sender
{
    NSMenu *searchMenu = [_searchOptionsPopup menu];
    NSInteger indexOfDivider = [searchMenu indexOfItem:_searchOptionsDividerItem];
    NSInteger selectedIndex = [_searchOptionsPopup indexOfSelectedItem];
    NSMenuItem *selectedItem = [sender selectedItem];

    // Was the selected menu item before or after the special menu divider?
    if (selectedIndex < indexOfDivider)
    {
        // Items before the divider indicate search flags. They are toggled.
        NSInteger oldState = [selectedItem state];

        [selectedItem setState:((oldState == NSOnState) ? NSOffState : NSOnState)];
    }
    else
    {
        // Items after the divider are previous search strings. Selecting one
        // puts it in the search field.
        [_searchField setStringValue:[selectedItem title]];
    }

    // Whatever we did changed the search parameters in some way, so re-perform
    // the search.
    [self doSearch:sender];
}

#pragma mark -
#pragma mark AKUIController methods

- (void)applyUserPreferences
{
    if (_AKFavoritesQuicklistMode == _selectedQuicklistMode)
    {
        NSArray *favoritesList = [[AKAppDelegate appDelegate] favoritesList];

        if (![favoritesList isEqual:_docLocators])  // [agl] review
        {
            [self _reloadQuicklistTable];
        }
    }

    [_quicklistTable applyListFontPrefs];
}

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
    [windowLayout setQuicklistMode:_selectedQuicklistMode];

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
#pragma mark DIGSFindBufferDelegate methods

- (void)findBufferDidChange:(DIGSFindBuffer *)findBuffer
{
    [_searchField setStringValue:[findBuffer findString]];
}

#pragma mark -
#pragma mark AKMultiRadioViewDelegate methods

- (void)multiRadioViewDidMakeSelection:(AKMultiRadioView *)mrv
{
    [self _selectQuicklistMode:[mrv selectedTag]];
}

#pragma mark -
#pragma mark NSUserInterfaceValidations methods

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

#pragma mark -
#pragma mark NSTableView datasource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_docLocators count];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)rowIndex
{
    return [[_docLocators objectAtIndex:rowIndex] stringToDisplayInLists];
}

#pragma mark -
#pragma mark NSTableView delegate methods

- (BOOL)tableView:(NSTableView*)tableView
       acceptDrop:(id <NSDraggingInfo>)info
              row:(int)row
    dropOperation:(NSTableViewDropOperation)operation
{
    if (_selectedQuicklistMode != _AKFavoritesQuicklistMode)
    {
        return NO;
    }

    if (row < 0)
    {
        return NO;
    }

    NSPasteboard *pboard = [info draggingPasteboard];
    NSArray *draggedRows = (NSArray *)[pboard propertyListForType:_AKQuicklistPasteboardType];

    if ([draggedRows count] == 0)
    {
        return NO;
    }

    int draggedRowIndex = [(NSNumber *)[draggedRows objectAtIndex:0] intValue];

    if ((draggedRowIndex < 0) || (draggedRowIndex == row))
    {
        return NO;
    }

    [[AKAppDelegate appDelegate] moveFavoriteFromIndex:draggedRowIndex
                                                     toIndex:row];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tableView
                validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(int)row
       proposedDropOperation:(NSTableViewDropOperation)operation
{
    if (_selectedQuicklistMode != _AKFavoritesQuicklistMode)
    {
        return NSDragOperationNone;
    }

    return operation;
}

- (BOOL)tableView:(NSTableView *)tableView
        writeRows:(NSArray*)rows
     toPasteboard:(NSPasteboard*)pboard
{
    if (_selectedQuicklistMode != _AKFavoritesQuicklistMode)
    {
        return NO;
    }

    [pboard declareTypes:@[_AKQuicklistPasteboardType] owner:self];
    [pboard setPropertyList:rows forType:_AKQuicklistPasteboardType];

    return YES;
}

#pragma mark -
#pragma mark Private methods

- (void)_selectQuicklistMode:(NSInteger)mode
{
    BOOL modeIsChanging = (mode != _selectedQuicklistMode);

    _selectedQuicklistMode = mode;

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

    switch (_selectedQuicklistMode)
    {
        case _AKFavoritesQuicklistMode:
        {
            NSArray *favoritesList = [[AKAppDelegate appDelegate] favoritesList];

            tableValues = [NSArray arrayWithArray:favoritesList];
            break;
        }

        case _AKCollectionClassesQuicklistMode:
        {
            tableValues = [self _collectionClasses];
            break;
        }

        case _AKWindowOrViewControllerClassesQuicklistMode:
        {
            tableValues = [self _windowOrViewControllerClasses];
            break;
        }

        case _AKViewClassesQuicklistMode:
        {
            tableValues = [self _viewClasses];
            break;
        }

        case _AKCellOrLayerClassesQuicklistMode:
        {
            tableValues = [self _cellOrLayerClasses];
            break;
        }

        case _AKClassesWithDelegatesQuicklistMode:
        {
            tableValues = [self _classesWithDelegates];
            break;
        }

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
            tableValues = @[];
            break;
        }
    }

    // Reload the table with the new values.
    [self setDocLocators:tableValues];
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
        NSArray *classNodes = [self _sortedDescendantsOfClassesWithNames:
                               @[@"NSString", @"NSAttributedString", @"NSData", @"NSValue", @"NSArray", @"NSDictionary", @"NSSet", @"NSDate", @"NSHashTable", @"NSMapTable", @"NSPointerArray"]];
        s_collectionClasses = [self _sortedDocLocatorsForClasses:classNodes];
    }

    return s_collectionClasses;
}

- (NSArray *)_windowOrViewControllerClasses
{
    static NSArray *s_windowOrViewControllerClasses = nil;

    if (!s_windowOrViewControllerClasses)
    {
#if APPKIDO_FOR_IPHONE
        NSArray *classNodes = [self _sortedDescendantsOfClassesWithNames:@[@"UIViewController"]];
#else
        NSArray *classNodes = [self _sortedDescendantsOfClassesWithNames:@[@"NSWindow"]];
#endif

        s_windowOrViewControllerClasses = [self _sortedDocLocatorsForClasses:classNodes];
    }

    return s_windowOrViewControllerClasses;
}

- (NSArray *)_viewClasses
{
    static NSArray *s_viewClasses = nil;

    if (!s_viewClasses)
    {
        NSString *nameOfRootViewClass;

        if ([[[self owningWindowController] database] classWithName:@"UIView"] != nil)
        {
            nameOfRootViewClass = @"UIView";
        }
        else
        {
            nameOfRootViewClass = @"NSView";
        }

        NSArray *classNodes = [self _sortedDescendantsOfClassesWithNames:@[nameOfRootViewClass]];

        s_viewClasses = [self _sortedDocLocatorsForClasses:classNodes];
    }

    return s_viewClasses;
}

- (NSArray *)_cellOrLayerClasses
{
    static NSArray *s_cellOrLayerClasses = nil;

    if (!s_cellOrLayerClasses)
    {
#if APPKIDO_FOR_IPHONE
        NSArray *classNodes = [self _sortedDescendantsOfClassesWithNames:@[@"CALayer"]];
#else
        NSArray *classNodes = [self _sortedDescendantsOfClassesWithNames:@[@"NSCell"]];
#endif

        s_cellOrLayerClasses = [self _sortedDocLocatorsForClasses:classNodes];
    }

    return s_cellOrLayerClasses;
}

- (NSArray *)_classesWithDelegates
{
    static NSArray *s_classesWithDelegates = nil;

    if (!s_classesWithDelegates)
    {
        NSMutableSet *nodeSet = [NSMutableSet set];

        for (AKClassNode *classNode in [[[self owningWindowController] database] allClasses])
        {
            BOOL classHasDelegate = NO;

            // See if the class doc contains a "Delegate Methods" section.
            AKFileSection *delegateMethodsSection = [[classNode nodeDocumentation] childSectionWithName:AKDelegateMethodsHTMLSectionName];

            if (!delegateMethodsSection)
            {
                delegateMethodsSection =[[classNode nodeDocumentation] childSectionWithName:AKDelegateMethodsAlternateHTMLSectionName];
            }

            if (delegateMethodsSection)
            {
                classHasDelegate = YES;
            }

            // If not, see if the class has a method with a name like setFooDelegate:.
            if (!classHasDelegate)
            {
                for (AKMethodNode *methodNode in [classNode documentedInstanceMethods])
                {
                    NSString *methodName = [methodNode nodeName];

                    if ([methodName hasPrefix:@"set"] && [methodName hasSuffix:@"Delegate:"])
                    {
                        classHasDelegate = YES;
                        break;
                    }
                }
            }

            // If not, see if the class has a property named "delegate" or "fooDelegate".
            if (!classHasDelegate)
            {
                for (AKPropertyNode *propertyNode in [classNode documentedProperties])
                {
                    NSString *propertyName = [propertyNode nodeName];

                    if ([propertyName isEqual:@"delegate"] || [propertyName hasSuffix:@"Delegate:"])
                    {
                        classHasDelegate = YES;
                        break;
                    }
                }
            }

            // If not, see if there's a protocol named thisClassDelegate.
            NSString *possibleDelegateProtocolName = [[classNode nodeName] stringByAppendingString:@"Delegate"];
            if ([[[self owningWindowController] database] protocolWithName:possibleDelegateProtocolName])
            {
                classHasDelegate = YES;
            }

            // We've checked all the ways we can tell if a class has a delegate.
            if (classHasDelegate)
            {
                [nodeSet addObject:classNode];
            }
        }

        NSArray *classNodes = [self _sortedDescendantsOfClassesInSet:nodeSet];
        s_classesWithDelegates = [self _sortedDocLocatorsForClasses:classNodes];
    }

    return s_classesWithDelegates;
}

- (NSArray *)_classesWithDataSources
{
    static NSArray *s_classesWithDataSources = nil;

    if (!s_classesWithDataSources)
    {
        NSMutableSet *nodeSet = [NSMutableSet set];

        for (AKClassNode *classNode in [[[self owningWindowController] database] allClasses])
        {
            BOOL classHasDataSource = NO;

            // See if the class has a -setDataSource: method.
            for (AKMethodNode *methodNode in [classNode documentedInstanceMethods])
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
                for (AKPropertyNode *propertyNode in [classNode documentedProperties])
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
            NSString *possibleDataSourceProtocolName = [[classNode nodeName] stringByAppendingString:@"DataSource"];
            if ([[[self owningWindowController] database] protocolWithName:possibleDataSourceProtocolName])
            {
                classHasDataSource = YES;
            }

            // We've checked all the ways we can tell if a class has a datasource.
            if (classHasDataSource)
            {
                [nodeSet addObject:classNode];
            }
        }

        NSArray *classNodes = [self _sortedDescendantsOfClassesInSet:nodeSet];
        s_classesWithDataSources = [self _sortedDocLocatorsForClasses:classNodes];
    }

    return s_classesWithDataSources;
}

- (NSArray *)_dataSourceProtocols
{
    static NSArray *s_dataSourceProtocols = nil;

    if (!s_dataSourceProtocols)
    {
        NSMutableArray *protocolNodes = [NSMutableArray array];

        for (AKProtocolNode *protocolNode in [[[self owningWindowController] database] allProtocols])
        {
            if ([[protocolNode nodeName] ak_contains:@"DataSource"])
            {
                [protocolNodes addObject:protocolNode];
            }
        }

        s_dataSourceProtocols = [self _sortedDocLocatorsForProtocols:protocolNodes];
    }

    return s_dataSourceProtocols;
}

- (NSArray *)_classesForFramework:(NSString *)fwName
{
    NSArray *classNodes = [[[self owningWindowController] database] classesForFrameworkNamed:fwName];

    return [self _sortedDocLocatorsForClasses:classNodes];
}

- (NSArray *)_sortedDocLocatorsForClasses:(NSArray *)classNodes
{
    NSMutableArray *quicklistItems = [NSMutableArray array];

    for (AKClassNode *classNode in classNodes)
    {
        // Don't list classes that don't have HTML documentation.  They
        // may have cropped up in header files and either not been
        // documented yet or intended for Apple's internal use.
        if ([classNode nodeDocumentation])
        {
            AKTopic *topic = [AKClassTopic topicWithClassNode:classNode];

            [quicklistItems addObject:[AKDocLocator withTopic:topic
                                                 subtopicName:nil
                                                      docName:nil]];
        }
    }

    return [AKSortUtils arrayBySortingArray:quicklistItems];
}

- (NSArray *)_sortedDocLocatorsForProtocols:(NSArray *)protocolNodes
{
    NSMutableArray *quicklistItems = [NSMutableArray array];

    for (AKProtocolNode *protocolNode in protocolNodes)
    {
        // Don't list protocols that don't have HTML documentation.  They
        // may have cropped up in header files and either not been
        // documented yet or intended for Apple's internal use.
        if ([protocolNode nodeDocumentation])
        {
            AKTopic *topic = [AKProtocolTopic topicWithProtocolNode:protocolNode];

            [quicklistItems addObject:[AKDocLocator withTopic:topic
                                                 subtopicName:nil
                                                      docName:nil]];
        }
    }

    return [AKSortUtils arrayBySortingArray:quicklistItems];
}

- (NSArray *)_sortedDescendantsOfClassesWithNames:(NSArray *)classNames
{
    NSMutableSet *nodeSet = [NSMutableSet setWithCapacity:100];

    for (NSString *name in classNames)
    {
        AKClassNode *classNode = [[[self owningWindowController] database] classWithName:name];

        [nodeSet unionSet:[classNode descendantClasses]];
    }

    return [AKSortUtils arrayBySortingSet:nodeSet];
}

- (NSArray *)_sortedDescendantsOfClassesInSet:(NSSet *)nodeSet
{
    NSMutableSet *resultSet = [NSMutableSet setWithCapacity:([nodeSet count] * 2)];

    // Add descendant classes of the classes that were found.
    for (AKClassNode *node in nodeSet)
    {
        [resultSet unionSet:[node descendantClasses]];
    }

    // Sort the classes we found and return the result.
    return [AKSortUtils arrayBySortingSet:resultSet];
}

- (void)_selectSearchResultAtIndex:(NSInteger)resultIndex
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
    if (resultIndex < 0)
    {
        resultIndex = [[_searchQuery queryResults] count] - 1;
    }
    else if ((unsigned)resultIndex > [[_searchQuery queryResults] count] - 1)
    {
        resultIndex = 0;
    }
    _indexWithinSearchResults = resultIndex;

    // Jump to the search result at the new position.
    [_quicklistTable deselectAll:nil];
    [_quicklistTable scrollRowToVisible:_indexWithinSearchResults];
    [_quicklistTable selectRowIndexes:[NSIndexSet indexSetWithIndex:_indexWithinSearchResults]
                 byExtendingSelection:NO];

    // Give the quicklist table focus and tell the owning window to navigate to
    // the selected search result.
    (void)[[_quicklistTable window] makeFirstResponder:_quicklistTable];
    [[_quicklistTable window] makeKeyAndOrderFront:nil];
    [self doQuicklistTableAction:nil];
}

- (void)_selectSearchResultWithPrefix:(NSString *)searchString
{
	NSString *lowercaseSearchString = [searchString lowercaseString];
    NSInteger searchResultIndex = 0;
    NSArray *searchResults = [_searchQuery queryResults];
    NSInteger numSearchResults = [searchResults count];
    NSInteger i;

    for (i = 0; i < numSearchResults; i++)
    {
        AKDocLocator *docLocator = [searchResults objectAtIndex:i];

        if ([[[docLocator sortName] lowercaseString] hasPrefix:lowercaseSearchString])
        {
            searchResultIndex = i;
            break;
        }
    }

    [self _selectSearchResultAtIndex:searchResultIndex];
}

- (void)_updatePastStringsInSearchOptionsPopup
{
    NSMenu *searchMenu = [_searchOptionsPopup menu];
    NSInteger indexOfDivider = [searchMenu indexOfItem:_searchOptionsDividerItem];
    NSInteger numMenuItems = [searchMenu numberOfItems];
    NSInteger i;

    // Remove the existing list of past search strings.
    for (i = indexOfDivider + 1; i < numMenuItems; i++)
    {
        [searchMenu removeItemAtIndex:(indexOfDivider + 1)];
    }

    // Add the new list.
    for (NSString *searchString in _pastSearchStrings)
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
