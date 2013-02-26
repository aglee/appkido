/*
 * AKDocListViewController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDocListViewController.h"

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

@implementation AKDocListViewController

@synthesize docListTable = _docListTable;

#pragma mark -
#pragma mark Getters and setters

- (void)setSubtopic:(AKSubtopic *)subtopic
{
    [_subtopicToDisplay autorelease];
    _subtopicToDisplay = [subtopic retain];
}

- (NSString *)docComment
{
    NSInteger docIndex = [_docListTable selectedRow];
    
    return ((docIndex >= 0)
            ? [[_subtopicToDisplay docAtIndex:docIndex] commentString]
            : @"");
}

#pragma mark -
#pragma mark Navigation

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
    NSInteger docIndex = -1;
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
        [_docListTable selectRowIndexes:[NSIndexSet indexSetWithIndex:docIndex] byExtendingSelection:NO];

        // Modify whereTo.
        AKDoc *docToDisplay = [_subtopicToDisplay docAtIndex:docIndex];
        [whereTo setDocName:[docToDisplay docName]];
    }
}

- (void)focusOnDocListTable
{
    (void)[[_docListTable window] makeFirstResponder:_docListTable];
}

#pragma mark -
#pragma mark Action methods

- (IBAction)doDocListTableAction:(id)sender
{
    NSInteger selectedRow = [_docListTable selectedRow];
    NSString *docName = ((selectedRow < 0)
                         ? nil
                         : [[_subtopicToDisplay docAtIndex:selectedRow] docName]);

    // Tell the main window to select the doc at the selected index.
    [[self browserWindowController] jumpToDocName:docName];
}

#pragma mark -
#pragma mark AKUIController methods

- (void)applyUserPreferences
{
    [_docListTable applyListFontPrefs];
}

- (BOOL)validateItem:(id)anItem
{
    return NO;
}

#pragma mark -
#pragma mark NSTableView datasource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_subtopicToDisplay numberOfDocs];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)rowIndex
{
    return [[_subtopicToDisplay docAtIndex:rowIndex] stringToDisplayInDocList];
}

@end
