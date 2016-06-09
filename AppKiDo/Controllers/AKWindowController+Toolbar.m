/*
 * AKWindowController_Toolbar.m
 *
 * Created by Andy Lee on Sun Jun 01 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKWindowController.h"

@implementation AKWindowController (Toolbar)

#pragma mark - Private constants -- toolbar identifiers

static NSString *_AKQuicklistToolID    = @"AKQuicklistToolID";
static NSString *_AKBrowserToolID      = @"AKBrowserToolID";
static NSString *_AKBackToolID         = @"AKBackToolID";
static NSString *_AKForwardToolID      = @"AKForwardToolID";
static NSString *_AKSuperclassToolID   = @"AKSuperclassToolID";
static NSString *_AKAddColumnToolID    = @"AKAddColumnToolID";
static NSString *_AKRemoveColumnToolID = @"AKRemoveColumnToolID";

#pragma mark - NSToolbar delegate methods

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
	 itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];

	if ([itemIdentifier isEqualToString:_AKQuicklistToolID]) {
		// Set item appearance.
		toolbarItem.label = @"Quicklist";
		toolbarItem.paletteLabel = @"Quicklist";
		toolbarItem.toolTip = @"Hide/show the Quicklist panel";
		toolbarItem.image = [NSImage imageNamed:@"quicklist-tool"];

		// Set item behavior.
		toolbarItem.action = @selector(toggleQuicklistDrawer:);
	} else if ([itemIdentifier isEqualToString:_AKBrowserToolID]) {
		// Set item appearance.
		toolbarItem.label = @"Browser";
		toolbarItem.paletteLabel = @"Browser";
		toolbarItem.toolTip = @"Hide/show the browser";
		toolbarItem.image = [NSImage imageNamed:@"browser-tool"];

		// Set item behavior.
		toolbarItem.action = @selector(toggleBrowserVisible:);
	} else if ([itemIdentifier isEqualToString:_AKBackToolID]) {
		// Set item appearance.
		toolbarItem.label = @"Back";
		toolbarItem.paletteLabel = @"Back";
		toolbarItem.toolTip = @"Go to previous item in navigation history";
		toolbarItem.image = [NSImage imageNamed:@"back-tool"];

		// Set item behavior.
		toolbarItem.action = @selector(goBackInHistory:);
	} else if ([itemIdentifier isEqualToString:_AKForwardToolID]) {
		// Set item appearance.
		toolbarItem.label = @"Forward";
		toolbarItem.paletteLabel = @"Forward";
		toolbarItem.toolTip = @"Go to next item in navigation history";
		toolbarItem.image = [NSImage imageNamed:@"forward-tool"];

		// Set item behavior.
		toolbarItem.action = @selector(goForwardInHistory:);
	} else if ([itemIdentifier isEqualToString:_AKSuperclassToolID]) {
		// Set item appearance.
		toolbarItem.label = @"Superclass";
		toolbarItem.paletteLabel = @"Superclass";
		toolbarItem.toolTip = @"Go to superclass of selected class";
		toolbarItem.image = [NSImage imageNamed:@"superclass-tool"];

		// Set item behavior.
		toolbarItem.action = @selector(selectSuperclass:);
	} else if ([itemIdentifier isEqualToString:_AKAddColumnToolID]) {
		// Set item appearance.
		toolbarItem.label = @"++Columns";
		toolbarItem.paletteLabel = @"++Columns";
		toolbarItem.toolTip = @"Add a column to the browser";
		toolbarItem.image = [NSImage imageNamed:@"add-column-tool"];

		// Set item behavior.
		toolbarItem.action = @selector(addBrowserColumn:);
	} else if ([itemIdentifier isEqualToString:_AKRemoveColumnToolID]) {
		// Set item appearance.
		toolbarItem.label = @"--Columns";
		toolbarItem.paletteLabel = @"--Columns";
		toolbarItem.toolTip = @"Remove a column from the browser";
		toolbarItem.image = [NSImage imageNamed:@"remove-column-tool"];

		// Set item behavior.
		toolbarItem.action = @selector(removeBrowserColumn:);
	} else {
		toolbarItem = nil;
	}

	return toolbarItem;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
	return @[
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
			 ];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return @[
			 _AKQuicklistToolID,
			 _AKBrowserToolID,
			 NSToolbarSeparatorItemIdentifier,
			 _AKBackToolID,
			 _AKForwardToolID,
			 _AKSuperclassToolID
			 ];
}

@end

