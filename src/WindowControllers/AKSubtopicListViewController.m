/*
 * AKSubtopicListViewController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSubtopicListViewController.h"

#import "AKDocLocator.h"
#import "AKSubtopic.h"
#import "AKTableView.h"
#import "AKTopic.h"
#import "AKWindowController.h"

@implementation AKSubtopicListViewController

@synthesize subtopicsTable = _subtopicsTable;

#pragma mark -
#pragma mark Init/dealloc/awake

- (id)initWithNibName:nibName windowController:(AKWindowController *)windowController
{
    self = [super initWithNibName:@"SubtopicListView" windowController:windowController];
    if (self)
    {
        _subtopics = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [_subtopics release];

    [super dealloc];
}

- (void)awakeFromNib
{
    // Use a custom cell for the subtopics table.
    NSBrowserCell *browserCell = [[[NSBrowserCell alloc] initTextCell:@""] autorelease];
    [browserCell setLeaf:NO];
    [browserCell setLoaded:YES];
    [[[_subtopicsTable tableColumns] objectAtIndex:0] setDataCell:browserCell];

    // Populate the subtopics table.
    [_subtopicsTable reloadData];
    [_subtopicsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

#pragma mark -
#pragma mark Getters and setters

- (AKSubtopic *)selectedSubtopic
{
    NSInteger subtopicIndex = [_subtopicsTable selectedRow];

    return ((subtopicIndex >= 0)
            ? [_subtopics objectAtIndex:subtopicIndex]
            : nil);
}

#pragma mark -
#pragma mark Action methods

- (IBAction)doSubtopicTableAction:(id)sender
{
    NSInteger selectedRow = [_subtopicsTable selectedRow];
    NSString *newSubtopicName = ((selectedRow < 0)
                                 ? nil
                                 : [[_subtopics objectAtIndex:selectedRow] subtopicName]);

    // Tell the main window to select the subtopic at the selected index.
    [[self owningWindowController] selectSubtopicWithName:newSubtopicName];
}

- (IBAction)selectSubtopicWithIndexFromTag:(id)sender
{
    [self _selectSubtopicWithIndex:[sender tag]];
}

#pragma mark -
#pragma mark Navigation

- (void)goFromDocLocator:(AKDocLocator *)whereFrom toDocLocator:(AKDocLocator *)whereTo
{
    // Is the topic changing?  (The "!=" test handles nil cases.)
    AKTopic *currentTopic = [whereFrom topicToDisplay];
    AKTopic *newTopic = [whereTo topicToDisplay];
    BOOL topicIsChanging = ((currentTopic != newTopic)
                            && ![currentTopic isEqual:newTopic]);
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
        // Modify whereTo.
        [whereTo setSubtopicName:nil];
    }
    else
    {
        // Figure out what subtopic index to select. If possible, select the
        // subtopic whose name matches the current one.
        NSInteger subtopicIndex = ((newSubtopicName == nil)
                                   ? [newTopic indexOfSubtopicWithName:currentSubtopicName]
                                   : [newTopic indexOfSubtopicWithName:newSubtopicName]);

        if (subtopicIndex < 0)
        {
            subtopicIndex = 0;
        }

        // Select the subtopic at that index.
        [_subtopicsTable scrollRowToVisible:subtopicIndex];
        [_subtopicsTable selectRowIndexes:[NSIndexSet indexSetWithIndex:subtopicIndex]
                     byExtendingSelection:NO];

        // Modify whereTo.
        AKSubtopic *subtopic = [_subtopics objectAtIndex:subtopicIndex];

        [whereTo setSubtopicName:[subtopic subtopicName]];
    }
}

#pragma mark -
#pragma mark AKUIController methods

- (void)applyUserPreferences
{
    [_subtopicsTable applyListFontPrefs];
}

- (BOOL)validateItem:(id)anItem
{
    SEL itemAction = [anItem action];

    if (itemAction == @selector(selectSubtopicWithIndexFromTag:))
    {
        return YES;
    }
    
    return NO;
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

- (void)tableView:(NSTableView *)aTableView
  willDisplayCell:(id)aCell
   forTableColumn:(NSTableColumn *)aTableColumn
              row:(NSInteger)rowIndex
{
    if ([aCell isKindOfClass:[NSBrowserCell class]])
    {
        AKSubtopic *subtopic = [_subtopics objectAtIndex:rowIndex];

        [aCell setLeaf:([subtopic numberOfDocs] == 0)];
    }
}

#pragma mark -
#pragma mark Private methods

- (void)_selectSubtopicWithIndex:(NSInteger)subtopicIndex
{
    if (subtopicIndex != [_subtopicsTable selectedRow])
    {
        NSString *newSubtopicName = [[_subtopics objectAtIndex:subtopicIndex] subtopicName];

        [[self owningWindowController] selectSubtopicWithName:newSubtopicName];
    }
}

@end
