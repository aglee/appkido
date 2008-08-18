/*
 * AKPrefPanelController.m
 *
 * Created by Andy Lee on Sat Sep 07 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKPrefPanelController.h"

#import "AKFrameworkConstants.h"
#import "AKPrefUtils.h"
#import "AKDatabase.h"
#import "AKAppController.h"
#import "AKDevToolsPathController.h"

//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKPrefPanelController (Private)

- (void)_updateAppearanceTabFromPrefs;
- (void)_updatePrefsFromAppearanceTab;
- (NSArray *)_namesOfAvailableFrameworks;

@end

@implementation AKPrefPanelController

//-------------------------------------------------------------------------
// Private constants
//-------------------------------------------------------------------------

static NSString *_AKCheckboxesColumnID     = @"checkboxes";
static NSString *_AKFrameworkNamesColumnID = @"frameworkNames";

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

static AKPrefPanelController *s_sharedInstance = nil;

+ (AKPrefPanelController *)sharedInstance
{
    if (!s_sharedInstance)
    {
        s_sharedInstance = [[self alloc] init];
    }

    return s_sharedInstance;
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)init
{
    if (s_sharedInstance)
    {
        [self dealloc];
        return s_sharedInstance;
    }

    if ((self = [super init]))
    {
        s_sharedInstance = self;
    }

    return self;
}

- (void)awakeFromNib
{
    [[_prefsTabView window] center];

    // Tweak the Frameworks table.
    NSButtonCell *checkboxCell =
        [[[NSButtonCell alloc] initTextCell:@""] autorelease];

    [checkboxCell setButtonType:NSSwitchButton];
    [[_frameworksTable
        tableColumnWithIdentifier:_AKCheckboxesColumnID]
        setDataCell:checkboxCell];
}

- (void)dealloc
{
    if (self != s_sharedInstance)
    {
        [super dealloc];
    }
}

//-------------------------------------------------------------------------
// Action methods
//-------------------------------------------------------------------------

- (IBAction)openPrefsPanel:(id)sender
{
    [self _updateAppearanceTabFromPrefs];

    if ([AKPrefUtils devToolsPathPref])
    {
        [_devToolsPathField setStringValue:[AKPrefUtils devToolsPathPref]];
    }
    else
    {
        [_devToolsPathField setStringValue:@""];
    }

    [[_prefsTabView window] makeKeyAndOrderFront:nil];
}

- (IBAction)applyAppearancePrefs:(id)sender
{
    [self _updatePrefsFromAppearanceTab];
    [(AKAppController *)[NSApp delegate] applyUserPreferences];
}

- (IBAction)useDefaultAppearancePrefs:(id)sender
{
    [AKPrefUtils resetAppearancePrefsToDefaults];
    [self _updateAppearanceTabFromPrefs];
    [(AKAppController *)[NSApp delegate] applyUserPreferences];
}

- (IBAction)selectDevToolsPath:(id)sender
{
    AKDevToolsPathController *pathPrompt =
        [AKDevToolsPathController controllerWithTextField:_devToolsPathField];
    [pathPrompt runOpenPanel];
}

- (IBAction)doFrameworksListAction:(id)sender
{
    if (sender == _frameworksTable)
    {
        if ([sender clickedColumn] == 0)
        {
            // The user toggled a framework.
            NSString *clickedFramework =
                [[self _namesOfAvailableFrameworks]
                    objectAtIndex:[sender clickedRow]];
            NSMutableArray *selectedFrameworks =
                [NSMutableArray
                    arrayWithArray:
                        [AKPrefUtils selectedFrameworkNamesPref]];

            if ([selectedFrameworks containsObject:clickedFramework])
            {
                [selectedFrameworks removeObject:clickedFramework];
            }
            else
            {
                [selectedFrameworks addObject:clickedFramework];
            }

            [AKPrefUtils setSelectedFrameworkNamesPref:selectedFrameworks];

            [_frameworksTable reloadData];
        }
    }
}

- (IBAction)selectAllFrameworks:(id)sender
{
    [AKPrefUtils setSelectedFrameworkNamesPref:[self _namesOfAvailableFrameworks]];
    [_frameworksTable reloadData];
}

- (IBAction)deselectAllFrameworks:(id)sender
{
    [AKPrefUtils setSelectedFrameworkNamesPref:AKNamesOfEssentialFrameworks];
    [_frameworksTable reloadData];
}

//-------------------------------------------------------------------------
// NSTableView datasource methods
//-------------------------------------------------------------------------

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [[self _namesOfAvailableFrameworks] count];
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
    return
        [[self _namesOfAvailableFrameworks]
            objectAtIndex:rowIndex];
}

//-------------------------------------------------------------------------
// NSTableView delegate methods
//-------------------------------------------------------------------------

- (void)tableView:(NSTableView *)aTableView
    willDisplayCell:(id)aCell
    forTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
    NSString *columnID = [aTableColumn identifier];
    NSString *fwName =
        [[self _namesOfAvailableFrameworks]
            objectAtIndex:rowIndex];

    if ([columnID isEqualToString:_AKCheckboxesColumnID])
    {
        if ([AKNamesOfEssentialFrameworks containsObject:fwName])
        {
            // Do not allow the user to remove "essential" frameworks.
            [aCell setEnabled:NO];
            [aCell setState:NSOnState];
        }
        else
        {
            // All other frameworks are up to the user to include or not.
            [aCell setEnabled:YES];

            if ([[AKPrefUtils selectedFrameworkNamesPref]
                    containsObject:fwName])
            {
                // The framework is currently included.
                [aCell setState:NSOnState];
            }
            else
            {
                // The framework is currently not included.
                [aCell setState:NSOffState];
            }
        }
    }
    else if ([columnID isEqualToString:_AKFrameworkNamesColumnID])
    {
        // The cell's title is the framework name.
        [aCell setTitle:fwName];
    }
}

@end

//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation AKPrefPanelController (Private)

// Update control settings in the prefs panel based on user preference
// values given by NSUserDefaults.
- (void)_updateAppearanceTabFromPrefs
{
    // The list-font-name pref.
    NSString *listFontName =
        [AKPrefUtils stringValueForPref:AKListFontNamePrefName];
    int listFontNameIndex =
        [_listFontNameChoice indexOfItemWithTitle:listFontName];

    if (listFontNameIndex < 0)
    {
        listFontNameIndex =
            [_listFontNameChoice indexOfItemWithTitle:@"Helvetica"];

        if (listFontNameIndex < 0)
        {
            listFontNameIndex = 0;
        }
    }
    [_listFontNameChoice selectItemAtIndex:listFontNameIndex];

    // The list-font-size pref.
    [_listFontSizeCombo setIntValue:
        [AKPrefUtils intValueForPref:AKListFontSizePrefName]];

    // The header-font-name pref.
    NSString *headerFontName =
        [AKPrefUtils stringValueForPref:AKHeaderFontNamePrefName];
    int headerFontNameIndex =
        [_headerFontNameChoice indexOfItemWithTitle:headerFontName];

    if (headerFontNameIndex < 0)
    {
        headerFontNameIndex =
            [_headerFontNameChoice indexOfItemWithTitle:@"Monaco"];

        if (headerFontNameIndex < 0)
        {
            headerFontNameIndex = 0;
        }
    }
    [_headerFontNameChoice selectItemAtIndex:headerFontNameIndex];

    // The header-font-size pref.
    [_headerFontSizeCombo setIntValue:
        [AKPrefUtils intValueForPref:AKHeaderFontSizePrefName]];

    // The doc-magnification pref.
    int magnificationChoiceTag =
        [AKPrefUtils intValueForPref:AKDocMagnificationPrefName];
    int magnificationIndex =
        [_magnificationChoice indexOfItemWithTag:magnificationChoiceTag];

    if (magnificationIndex < 0)
    {
        magnificationIndex =
            [_magnificationChoice indexOfItemWithTag:100];
    }
    [_magnificationChoice selectItemAtIndex:magnificationIndex];

    // The small-contextual-menus pref.
    // [agl] fill in small-contextual-menus pref
}

// Update the user preference settings in NSUserDefaults based on control
// settings in the prefs panel.
- (void)_updatePrefsFromAppearanceTab
{
    // The list-font-name pref.
    [AKPrefUtils
        setStringValue:[[_listFontNameChoice selectedItem] title]
        forPref:AKListFontNamePrefName];

    // The list-font-size pref.
    [AKPrefUtils
        setIntValue:[_listFontSizeCombo intValue]
        forPref:AKListFontSizePrefName];

    // The header-font-name pref.
    [AKPrefUtils
        setStringValue:[[_headerFontNameChoice selectedItem] title]
        forPref:AKHeaderFontNamePrefName];

    // The header-font-size pref.
    [AKPrefUtils
        setIntValue:[_headerFontSizeCombo intValue]
        forPref:AKHeaderFontSizePrefName];

    // The doc-magnification pref.
    [AKPrefUtils
        setIntValue:[_magnificationChoice selectedTag]
        forPref:AKDocMagnificationPrefName];

    // The small-contextual-menus pref.
    // [agl] fill in small-contextual-menus pref
}

- (NSArray *)_namesOfAvailableFrameworks
{
    return [[AKDatabase defaultDatabase] namesOfAvailableFrameworks];
}

@end
