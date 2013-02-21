/*
 * AKWindowController_Toolbar.m
 *
 * Created by Andy Lee on Sun Jun 01 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKWindowController.h"

@implementation AKWindowController (Toolbar)


#pragma mark -
#pragma mark Private constants -- toolbar identifiers

static NSString *_AKQuicklistToolID    = @"AKQuicklistToolID";
static NSString *_AKBrowserToolID      = @"AKBrowserToolID";
static NSString *_AKBackToolID         = @"AKBackToolID";
static NSString *_AKForwardToolID      = @"AKForwardToolID";
static NSString *_AKSuperclassToolID   = @"AKSuperclassToolID";
static NSString *_AKAddColumnToolID    = @"AKAddColumnToolID";
static NSString *_AKRemoveColumnToolID = @"AKRemoveColumnToolID";


#pragma mark -
#pragma mark NSToolbar delegate methods

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
    itemForItemIdentifier:(NSString *)itemIdentifier
    willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *toolbarItem =
        [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    
    if ([itemIdentifier isEqualToString:_AKQuicklistToolID])
    {
        // Set item appearance.
        [toolbarItem setLabel:@"Quicklist"];
        [toolbarItem setPaletteLabel:@"Quicklist"];
        [toolbarItem setToolTip:@"Hide/show the Quicklist panel (Command-K)"];
        [toolbarItem setImage:[NSImage imageNamed:@"quicklist-tool"]];

        // Set item behavior.
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(toggleQuicklistDrawer:)];
    }
    else if ([itemIdentifier isEqualToString:_AKBrowserToolID])
    {
        // Set item appearance.
        [toolbarItem setLabel:@"Browser"];
        [toolbarItem setPaletteLabel:@"Browser"];
        [toolbarItem setToolTip:@"Hide/show the browser (Command-B)"];
        [toolbarItem setImage:[NSImage imageNamed:@"browser-tool"]];

        // Set item behavior.
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(toggleBrowserVisible:)];
    }
    else if ([itemIdentifier isEqualToString:_AKBackToolID])
    {
        // Set item appearance.
        [toolbarItem setLabel:@"Back"];
        [toolbarItem setPaletteLabel:@"Back"];
        [toolbarItem setToolTip:@"Go to previous item in navigation history "
                                @"(Command-LeftArrow)"];
        [toolbarItem setImage:[NSImage imageNamed:@"back-tool"]];

        // Set item behavior.
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(navigateBack:)];
    }
    else if ([itemIdentifier isEqualToString:_AKForwardToolID])
    {
        // Set item appearance.
        [toolbarItem setLabel:@"Forward"];
        [toolbarItem setPaletteLabel:@"Forward"];
        [toolbarItem setToolTip:@"Go to next item in navigation history "
                                @"(Command-RightArrow)"];
        [toolbarItem setImage:[NSImage imageNamed:@"forward-tool"]];

        // Set item behavior.
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(navigateForward:)];
    }
    else if ([itemIdentifier isEqualToString:_AKSuperclassToolID])
    {
        // Set item appearance.
        [toolbarItem setLabel:@"Superclass"];
        [toolbarItem setPaletteLabel:@"Superclass"];
        [toolbarItem setToolTip:@"Go to superclass of selected class "
                                @"(Command-UpArrow)"];
        [toolbarItem setImage:[NSImage imageNamed:@"superclass-tool"]];

        // Set item behavior.
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(jumpToSuperclass:)];
    }
    else if ([itemIdentifier isEqualToString:_AKAddColumnToolID])
    {
        // Set item appearance.
        [toolbarItem setLabel:@"++Columns"];
        [toolbarItem setPaletteLabel:@"++Columns"];
        [toolbarItem setToolTip:@"Add a column to the browser (Command-+)"];
        [toolbarItem setImage:[NSImage imageNamed:@"add-column-tool"]];

        // Set item behavior.
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(addBrowserColumn:)];
    }
    else if ([itemIdentifier isEqualToString:_AKRemoveColumnToolID])
    {
        // Set item appearance.
        [toolbarItem setLabel:@"--Columns"];
        [toolbarItem setPaletteLabel:@"--Columns"];
        [toolbarItem setToolTip:@"Remove a column from the browser "
                                @"(Command--)"];
        [toolbarItem setImage:[NSImage imageNamed:@"remove-column-tool"]];

        // Set item behavior.
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(removeBrowserColumn:)];
    }
    else
    {
        toolbarItem = nil;
    }

    return toolbarItem;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return
        [NSArray arrayWithObjects:
            _AKQuicklistToolID,
            _AKBrowserToolID,
            _AKBackToolID,
            _AKForwardToolID,
            _AKSuperclassToolID,
            _AKAddColumnToolID,
            _AKRemoveColumnToolID,
            NSToolbarSeparatorItemIdentifier,
            NSToolbarSpaceItemIdentifier,
            NSToolbarFlexibleSpaceItemIdentifier,
            nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return
        [NSArray arrayWithObjects:
            _AKQuicklistToolID,
            _AKBrowserToolID,
            NSToolbarSeparatorItemIdentifier,
            _AKBackToolID,
            _AKForwardToolID,
            _AKSuperclassToolID,
            nil];
}

@end

