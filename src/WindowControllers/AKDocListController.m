/*
 * AKDocListController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDocListController.h"

#import <WebKit/WebKit.h>
#import "DIGSLog.h"
#import "AKFileSection.h"
#import "AKDatabase.h"
#import "AKWindowController.h"
#import "AKAppController.h"
#import "AKTableView.h"
#import "AKDoc.h"
#import "AKTopic.h"
#import "AKSubtopic.h"
#import "AKDocLocator.h"
#import "AKDocView.h"

@implementation AKDocListController

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (void)dealloc
{
    [_subtopicToDisplay release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (void)setSubtopic:(AKSubtopic *)subtopic
{
    [subtopic retain];
    [_subtopicToDisplay release];
    _subtopicToDisplay = subtopic;
}

- (AKDoc *)currentDoc
{
    int docIndex = [_docListTable selectedRow];

    if (docIndex < 0)
    {
        return nil;
    }

    return [_subtopicToDisplay docAtIndex:docIndex];
}

//-------------------------------------------------------------------------
// Navigation
//-------------------------------------------------------------------------

- (void)navigateFrom:(AKDocLocator *)whereFrom to:(AKDocLocator *)whereTo
{
    // Handle cases where there's nothing to do.
    if ([whereFrom isEqual:whereTo])
    {
        return;
    }

// [agl] handle case where inherited -foo is selected, change to superclass,
// so doc for -foo is same -- should NOT change the text view

// [agl] make Class Description interchangeable with Protocol Description

    // Reload the doc list table.
    [_docListTable reloadData];
    int docIndex = -1;
    if ([_subtopicToDisplay numberOfDocs] == 0)
    {
        // Modify whereTo.
        [whereTo setDocName:nil];
    }
    else
    {
        // Figure out what row index to select in the doc list table.
        NSString *docName = [whereTo docName];

        if (docName == nil)
        {
            docIndex = 0;
        }
        else
        {
            docIndex = [_subtopicToDisplay indexOfDocWithName:docName];
            if (docIndex < 0)
            {
                docIndex = 0;
            }
        }

        // Select the doc at that index.
        [_docListTable scrollRowToVisible:docIndex];
        [_docListTable selectRow:docIndex byExtendingSelection:NO];

        // Modify whereTo.
        AKDoc *docToDisplay = [_subtopicToDisplay docAtIndex:docIndex];
        [whereTo setDocName:[docToDisplay docName]];
    }

    // Display the doc text.
    [_docView setDocLocator:whereTo];

    // Display the doc comment.
    NSString *docComment =
        (docIndex >= 0)
        ? [[_subtopicToDisplay docAtIndex:docIndex] commentString]
        : @"";

    [_docCommentField setStringValue:docComment];
}

- (void)focusOnDocListTable
{
    (void)[[_docListTable window] makeFirstResponder:_docListTable];
}

//-------------------------------------------------------------------------
// Action methods
//-------------------------------------------------------------------------

- (IBAction)doDocListTableAction:(id)sender
{
    int selectedRow = [_docListTable selectedRow];
    NSString *docName =
        (selectedRow < 0)
        ? nil
        : [[_subtopicToDisplay docAtIndex:selectedRow] docName];

    // Tell the main window to select the doc at the selected index.
    [_windowController jumpToDocName:docName];
}

//-------------------------------------------------------------------------
// AKSubcontroller methods
//-------------------------------------------------------------------------

- (void)applyUserPreferences
{
    // Update the doc list table.
    [_docListTable applyListFontPrefs];

    // Update the doc text view.
    [_docView applyPrefs];
}

- (BOOL)validateItem:(id)anItem
{
    return NO;
}

//-------------------------------------------------------------------------
// NSTableView datasource methods
//-------------------------------------------------------------------------

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_subtopicToDisplay numberOfDocs];
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
    return
        [[_subtopicToDisplay docAtIndex:rowIndex]
            stringToDisplayInDocList];
}

//-------------------------------------------------------------------------
// WebPolicyDelegate methods
//-------------------------------------------------------------------------

- (void)webView:(WebView *)sender
    decidePolicyForNavigationAction:(NSDictionary *)actionInformation
    request:(NSURLRequest *)request
    frame:(WebFrame *)frame
    decisionListener:(id <WebPolicyDecisionListener>)listener
{
    NSNumber *navType =
        [actionInformation objectForKey:WebActionNavigationTypeKey];
    BOOL isLinkClicked =
        ((navType != nil)
            && ([navType intValue] == WebNavigationTypeLinkClicked));

    if (isLinkClicked)
    {
        NSEvent *currentEvent = [NSApp currentEvent];
        AKWindowController *wc =
            ([currentEvent modifierFlags] & NSCommandKeyMask)
            ? [[NSApp delegate] controllerForNewWindow]
            : _windowController;

        // Use a delayed perform to avoid mucking with the WebView's
        // display while it's in the middle of processing a UI event.
        // Note that the return value of -jumpToLinkURL: will be lost.
        [wc
            performSelector:@selector(jumpToLinkURL:)
            withObject:[request URL]
            afterDelay:0];
    }
    else
    {
        [listener use];
    }
}

//-------------------------------------------------------------------------
// WebUIDelegate methods
//-------------------------------------------------------------------------

- (NSArray *)webView:(WebView *)sender
    contextMenuItemsForElement:(NSDictionary *)element
    defaultMenuItems:(NSArray *)defaultMenuItems
{
    NSURL *linkURL = [element objectForKey:WebElementLinkURLKey];
    NSMutableArray *newMenuItems = [NSMutableArray array];

    // Loop through the proposed menu items in defaultMenuItems, and only
    // allow certain ones of them to appear in the contextual menu, because
    // the others don't make sense for us.
    //
    // Note that we may come across some tags for which there aren't
    // WebMenuItemXXX constants declared in the version of WebKit
    // I'm using.  For example, the "Reload" menu item has tag 12,
    // which is WebMenuItemTagReload in newer versions of WebKit.
    // That's okay -- as of this writing, none of those are things
    // we want in the menu.
    NSEnumerator *en = [defaultMenuItems objectEnumerator];
    NSMenuItem *menuItem;

    while ((menuItem = [en nextObject]))
    {
        int tag = [menuItem tag];

        if (tag == WebMenuItemTagOpenLinkInNewWindow)
        {
            // Change this menu item so instead of opening the link
            // in a new *web* browser window, it opens a new *AppKiDo*
            // browser window.
            [menuItem setAction:@selector(openLinkInNewWindow:)];
            [menuItem setTarget:nil];  // will go to first responder
            [menuItem setRepresentedObject:linkURL];

            [newMenuItems addObject:menuItem];
        }
        else if ((tag == WebMenuItemTagCopyLinkToClipboard)
            || (tag == WebMenuItemTagDownloadImageToDisk)
            || (tag == WebMenuItemTagCopyImageToClipboard)
            || (tag == WebMenuItemTagCopyImageToClipboard)
            || (tag == WebMenuItemTagCopy))
        {
            [newMenuItems addObject:menuItem];
        }
    }

    // Add an item to the menu that allows the user to copy the URL
    // of the file being looked at to the clipboard.  The URL could
    // then be pasted into an email message if the user is answering
    // somebody's question on one of the dev lists, for example.  The
    // URL could also be helpful for debugging.
    NSMenuItem *copyURLItem =
        [[[NSMenuItem alloc]
            initWithTitle:@"Copy Page URL"
            action:@selector(copyDocTextURL:)
            keyEquivalent:@""]
            autorelease];
    [copyURLItem setTarget:nil];  // will go to first responder
    [newMenuItems addObject:copyURLItem];

    // Add an item to the menu that allows the user to open the
    // currently displayed file in the default web browser.
    NSMenuItem *openURLInBrowserItem =
        [[[NSMenuItem alloc]
            initWithTitle:@"Open Page in Browser"
            action:@selector(openDocURLInBrowser:)
            keyEquivalent:@""]
            autorelease];
    [openURLInBrowserItem setTarget:nil];  // will go to first responder
    [newMenuItems addObject:openURLInBrowserItem];

    // Add an item to the menu that allows the user to reveal the
    // currently displayed file in the Finder.
    NSMenuItem *revealInFinderItem =
        [[[NSMenuItem alloc]
            initWithTitle:@"Reveal In Finder"
            action:@selector(revealDocFileInFinder:)
            keyEquivalent:@""]
            autorelease];
    [revealInFinderItem setTarget:nil];  // will go to first responder
    [newMenuItems addObject:revealInFinderItem];

    return newMenuItems;
}

@end
