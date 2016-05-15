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
#import "AKDocLocator.h"
#import "AKNamedObject.h"
#import "AKSubtopic.h"
#import "AKTableView.h"
#import "AKToken.h"
#import "AKTopic.h"
#import "AKWindowController.h"
#import <WebKit/WebKit.h>

@implementation AKDocListViewController

@synthesize subtopic = _subtopic;
@synthesize docListTable = _docListTable;

#pragma mark - Init/dealloc/awake

- (instancetype)initWithNibName:nibName windowController:(AKWindowController *)windowController
{
	return [super initWithNibName:@"DocListView" windowController:windowController];
}

#pragma mark - Getters and setters

- (NSString *)docComment
{
	NSInteger docIndex = self.docListTable.selectedRow;
	return (docIndex < 0
			? @""
			: [self.subtopic docAtIndex:docIndex].commentString);
}

#pragma mark - Navigation

- (void)focusOnDocListTable
{
	(void)[self.docListTable.window makeFirstResponder:self.docListTable];
}

#pragma mark - Action methods

// Tell the window to select the doc at the selected index.
- (IBAction)doDocListTableAction:(id)sender
{
	NSInteger selectedRow = self.docListTable.selectedRow;
	NSString *docName = (selectedRow < 0
						 ? nil
						 : [self.subtopic docAtIndex:selectedRow].name);
	[self.owningWindowController selectDocWithName:docName];
}

#pragma mark - AKViewController methods

- (void)goFromDocLocator:(AKDocLocator *)whereFrom toDocLocator:(AKDocLocator *)whereTo
{
	// Handle cases where there's nothing to do.
	if ([whereFrom isEqual:whereTo]) {
		return;
	}

	//TODO: handle case where inherited -foo is selected, change to superclass,
	// so doc for -foo is same -- should NOT change the text view

	//TODO: make Class Description interchangeable with Protocol Description

	// Reload the doc list table.
	[self.docListTable reloadData];

	NSInteger docIndex = -1;
	if (self.subtopic.docListItems.count == 0) {
		// Modify whereTo.
		[whereTo setDocName:nil];
	} else {
		// Figure out what row index to select in the doc list table.
		NSString *docName = whereTo.docName;
		if (docName == nil) {
			docIndex = 0;
		} else {
			docIndex = [self.subtopic indexOfDocWithName:docName];
			if (docIndex < 0) {
				docIndex = 0;
			}
		}

		// Select the doc at that index.
		[self.docListTable scrollRowToVisible:docIndex];
		[self.docListTable selectRowIndexes:[NSIndexSet indexSetWithIndex:docIndex]
				   byExtendingSelection:NO];

		// Modify whereTo.
		whereTo.docName = [self.subtopic docAtIndex:docIndex].name;
	}
}

#pragma mark - AKUIController methods

- (void)applyUserPreferences
{
	[self.docListTable applyListFontPrefs];
}

#pragma mark - NSUserInterfaceValidations methods

- (BOOL)validateUserInterfaceItem:(id)anItem
{
	return NO;
}

#pragma mark - NSTableView datasource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return self.subtopic.docListItems.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return [self.subtopic docAtIndex:rowIndex].displayName;
}

@end
