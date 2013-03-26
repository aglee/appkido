/*
 * AKSubtopicListViewController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSubtopicListViewController.h"

#import "AKBehaviorTopic.h"
#import "AKDocLocator.h"
#import "AKHeaderFileDoc.h"
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

- (IBAction)selectOverviewSubtopic:(id)sender
{
    [[self owningWindowController] selectSubtopicWithName:AKOverviewSubtopicName];
}

- (IBAction)selectHeaderFile:(id)sender
{
    AKDocLocator *oldDocLocator = [[self owningWindowController] currentDocLocator];
    AKDocLocator *newDocLocator = [[[AKDocLocator alloc] initWithTopic:[oldDocLocator topicToDisplay]
                                                          subtopicName:AKOverviewSubtopicName
                                                               docName:AKHeaderFileDocName] autorelease];
    [[self owningWindowController] selectDocWithDocLocator:newDocLocator];
}

- (IBAction)selectPropertiesSubtopic:(id)sender
{
    [[self owningWindowController] selectSubtopicWithName:AKPropertiesSubtopicName];
}

- (IBAction)selectAllPropertiesSubtopic:(id)sender
{
    [[self owningWindowController] selectSubtopicWithName:AKAllPropertiesSubtopicName];
}

- (IBAction)selectClassMethodsSubtopic:(id)sender
{
    [[self owningWindowController] selectSubtopicWithName:AKClassMethodsSubtopicName];
}

- (IBAction)selectAllClassMethodsSubtopic:(id)sender
{
    [[self owningWindowController] selectSubtopicWithName:AKAllClassMethodsSubtopicName];
}

- (IBAction)selectInstanceMethodsSubtopic:(id)sender
{
    [[self owningWindowController] selectSubtopicWithName:AKInstanceMethodsSubtopicName];
}

- (IBAction)selectAllInstanceMethodsSubtopic:(id)sender
{
    [[self owningWindowController] selectSubtopicWithName:AKAllInstanceMethodsSubtopicName];
}

- (IBAction)selectDelegateMethodsSubtopic:(id)sender
{
    [[self owningWindowController] selectSubtopicWithName:AKDelegateMethodsSubtopicName];
}

- (IBAction)selectAllDelegateMethodsSubtopic:(id)sender
{
    [[self owningWindowController] selectSubtopicWithName:AKAllDelegateMethodsSubtopicName];
}

- (IBAction)selectNotificationsSubtopic:(id)sender
{
    [[self owningWindowController] selectSubtopicWithName:AKNotificationsSubtopicName];
}

- (IBAction)selectAllNotificationsSubtopic:(id)sender
{
    [[self owningWindowController] selectSubtopicWithName:AKAllNotificationsSubtopicName];
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

#pragma mark -
#pragma mark NSUserInterfaceValidations methods

- (BOOL)validateUserInterfaceItem:(id)anItem
{
    SEL itemAction = [anItem action];

    if ((itemAction == @selector(selectOverviewSubtopic:))
        || (itemAction == @selector(selectHeaderFile:))
        || (itemAction == @selector(selectPropertiesSubtopic:))
        || (itemAction == @selector(selectAllPropertiesSubtopic:))
        || (itemAction == @selector(selectClassMethodsSubtopic:))
        || (itemAction == @selector(selectAllClassMethodsSubtopic:))
        || (itemAction == @selector(selectInstanceMethodsSubtopic:))
        || (itemAction == @selector(selectAllInstanceMethodsSubtopic:))
        || (itemAction == @selector(selectDelegateMethodsSubtopic:))
        || (itemAction == @selector(selectAllDelegateMethodsSubtopic:))
        || (itemAction == @selector(selectNotificationsSubtopic:))
        || (itemAction == @selector(selectAllNotificationsSubtopic:)))
    {
        AKTopic *currentTopic = [[[self owningWindowController] currentDocLocator] topicToDisplay];
        return [currentTopic isKindOfClass:[AKBehaviorTopic class]];
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

@end
