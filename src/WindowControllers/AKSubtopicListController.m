/*
 * AKSubtopicListController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSubtopicListController.h"

#import "AKWindowController.h"
#import "AKTableView.h"
#import "AKTopic.h"
#import "AKSubtopic.h"
#import "AKDocListController.h"
#import "AKDocLocator.h"

@implementation AKSubtopicListController


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)init
{
    if ((self = [super init]))
    {
        _subtopics = [[NSMutableArray alloc] init];
    }

    return self;
}



#pragma mark -
#pragma mark Navigation

- (void)navigateFrom:(AKDocLocator *)whereFrom to:(AKDocLocator *)whereTo
{
    // Is the topic changing?  (The "!=" test handles nil cases.)
    AKTopic *currentTopic = [whereFrom topicToDisplay];
    AKTopic *newTopic = [whereTo topicToDisplay];
    BOOL topicIsChanging =
        (currentTopic != newTopic) && ![currentTopic isEqual:newTopic];

    if (topicIsChanging)
    {
        // Update the arrays of table values and reload the subtopics table.
        NSInteger numSubtopics = [newTopic numberOfSubtopics];
        NSInteger i;

        [_subtopics removeAllObjects];
        for (i = 0; i < numSubtopics; i++)
        {
            AKSubtopic *subtopic = [newTopic subtopicAtIndex:i];

            [_subtopics addObject:subtopic];
        }
        [_subtopicsTable reloadData];
    }

    // Update the selection in the subtopics table.
    NSString *currentSubtopicName = [whereFrom subtopicName];
    NSString *newSubtopicName = [whereTo subtopicName];
    if ([_subtopics count] == 0)
    {
        // The subtopics table and doc list table will both be empty.
        [_docListController setSubtopic:nil];

        // Modify whereTo.
        [whereTo setSubtopicName:nil];
    }
    else
    {
        // Figure out what subtopic index to select.  Try to select the
        // subtopic whose name matches the current one.
        NSInteger subtopicIndex =
            (newSubtopicName == nil)
            ? [newTopic indexOfSubtopicWithName:currentSubtopicName]
            : [newTopic indexOfSubtopicWithName:newSubtopicName];

        if (subtopicIndex < 0)
        {
            subtopicIndex = 0;
        }

        // Select the subtopic at that index.
        [_subtopicsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:subtopicIndex] byExtendingSelection:NO];

        AKSubtopic *subtopic = [_subtopics objectAtIndex:subtopicIndex];

        [_docListController setSubtopic:subtopic];

        // Modify whereTo.
        [whereTo setSubtopicName:[subtopic subtopicName]];
    }

    // Tell my subordinate controllers to navigate.
    [_docListController navigateFrom:whereFrom to:whereTo];
}

- (void)jumpToSubtopicWithIndex:(NSInteger)subtopicIndex
{
    if (subtopicIndex != [_subtopicsTable selectedRow])
    {
        NSString *newSubtopicName =
            [[_subtopics objectAtIndex:subtopicIndex]
                subtopicName];

        [_windowController jumpToSubtopicWithName:newSubtopicName];
        [_docListController focusOnDocListTable];
    }
}


#pragma mark -
#pragma mark Action methods

- (IBAction)doSubtopicTableAction:(id)sender
{
    NSInteger selectedRow = [_subtopicsTable selectedRow];
    NSString *newSubtopicName =
        (selectedRow < 0)
        ? nil
        : [[_subtopics objectAtIndex:selectedRow] subtopicName];

    // Tell the main window to select the subtopic at the selected index.
    [_windowController jumpToSubtopicWithName:newSubtopicName];
}


#pragma mark -
#pragma mark AKSubcontroller methods

- (void)doAwakeFromNib
{
    NSBrowserCell *browserCell;

    // Tweak the subtopics table.
    browserCell = [[NSBrowserCell alloc] initTextCell:@""];
    [browserCell setLeaf:NO];
    [browserCell setLoaded:YES];
    [[[_subtopicsTable tableColumns] objectAtIndex:0]
        setDataCell:browserCell];

    // Populate the subtopics table.
    [_subtopicsTable reloadData];
    [_subtopicsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];

    // Tell subordinate controllers to awake.
    [_docListController doAwakeFromNib];
}

- (void)applyUserPreferences
{
    [_subtopicsTable applyListFontPrefs];

    [_docListController applyUserPreferences];
}

- (BOOL)validateItem:(id)anItem
{
    return [_docListController validateItem:anItem];
}


#pragma mark -
#pragma mark NSTableView datasource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_subtopics count];
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(NSInteger)rowIndex
{
    return [[_subtopics objectAtIndex:rowIndex] stringToDisplayInSubtopicList];
}


#pragma mark -
#pragma mark NSTableView delegate methods

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell
    forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if ([aCell isKindOfClass:[NSBrowserCell class]])
    {
        AKSubtopic *subtopic = [_subtopics objectAtIndex:rowIndex];

        [aCell setLeaf:([subtopic numberOfDocs] == 0)];
    }
}

@end

