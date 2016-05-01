/*
 * AKDocListViewController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDocListViewController.h"
#import "DIGSLog.h"
#import "AKAppDelegate.h"
#import "AKDatabase.h"
#import "AKDoc.h"
#import "AKDocLocator.h"
#import "AKSubtopic.h"
#import "AKTableView.h"
#import "AKTopic.h"
#import "AKWindowController.h"
#import <WebKit/WebKit.h>

@implementation AKDocListViewController

@synthesize subtopic = _subtopic;
@synthesize docListTable = _docListTable;

#pragma mark - Init/dealloc/awake

- (instancetype)initWithNibName:nibName windowController:(AKWindowController *)windowController
{
    self = [super initWithNibName:@"DocListView" windowController:windowController];
    if (self)
    {
    }

    return self;
}


#pragma mark - Getters and setters

- (NSString *)docComment
{
    NSInteger docIndex = _docListTable.selectedRow;
    
    return ((docIndex >= 0)
            ? [[_subtopic docAtIndex:docIndex] commentString]
            : @"");
}

#pragma mark - Navigation

- (void)focusOnDocListTable
{
    (void)[_docListTable.window makeFirstResponder:_docListTable];
}

#pragma mark - Action methods

- (IBAction)doDocListTableAction:(id)sender
{
    NSInteger selectedRow = _docListTable.selectedRow;
    NSString *docName = ((selectedRow < 0)
                         ? nil
                         : [[_subtopic docAtIndex:selectedRow] docName]);

    // Tell the main window to select the doc at the selected index.
    [self.owningWindowController selectDocWithName:docName];
}

#pragma mark - AKViewController methods

- (void)goFromDocLocator:(AKDocLocator *)whereFrom toDocLocator:(AKDocLocator *)whereTo
{
    // Handle cases where there's nothing to do.
    if ([whereFrom isEqual:whereTo])
    {
        return;
    }

//TODO: handle case where inherited -foo is selected, change to superclass,
// so doc for -foo is same -- should NOT change the text view

//TODO: make Class Description interchangeable with Protocol Description

    // Reload the doc list table.
    [_docListTable reloadData];
    
    NSInteger docIndex = -1;
    
    if ([_subtopic numberOfDocs] == 0)
    {
        // Modify whereTo.
        [whereTo setDocName:nil];
    }
    else
    {
        // Figure out what row index to select in the doc list table.
        NSString *docName = whereTo.docName;

        if (docName == nil)
        {
            docIndex = 0;
        }
        else
        {
            docIndex = [_subtopic indexOfDocWithName:docName];
            if (docIndex < 0)
            {
                docIndex = 0;
            }
        }

        // Select the doc at that index.
        [_docListTable scrollRowToVisible:docIndex];
        [_docListTable selectRowIndexes:[NSIndexSet indexSetWithIndex:docIndex]
                   byExtendingSelection:NO];

        // Modify whereTo.
        AKDoc *docToDisplay = [_subtopic docAtIndex:docIndex];
        whereTo.docName = [docToDisplay docName];
    }
}

#pragma mark - AKUIController methods

- (void)applyUserPreferences
{
    [_docListTable applyListFontPrefs];
}

#pragma mark - NSUserInterfaceValidations methods

- (BOOL)validateUserInterfaceItem:(id)anItem
{
    return NO;
}

#pragma mark - NSTableView datasource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_subtopic numberOfDocs];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)rowIndex
{
    return [[_subtopic docAtIndex:rowIndex] stringToDisplayInDocList];
}

@end
