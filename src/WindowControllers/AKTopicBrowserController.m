/*
 * AKTopicBrowserController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopicBrowserController.h"

#import "DIGSLog.h"

#import "AKPrefUtils.h"
#import "AKSortUtils.h"
#import "AKWindowController.h"
#import "AKDatabase.h"
#import "AKLabelTopic.h"
#import "AKClassTopic.h"
#import "AKFrameworkTopic.h"
#import "AKBrowser.h"
#import "AKSubtopicListController.h"
#import "AKDocLocator.h"
#import "AKTopic.h"
#import "AKClassNode.h"
#import "AKProtocolNode.h"


#pragma mark -
#pragma mark Forward declarations of private methods

@interface AKTopicBrowserController (Private)
- (NSInteger)_numberOfRowsInColumn:(NSInteger)column;
- (void)_setUpChildTopics;
- (void)_setUpTopicsForZeroethBrowserColumn;
@end


@implementation AKTopicBrowserController


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)init
{
    if ((self = [super init]))
    {
        _topicListsForBrowserColumns = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [_topicListsForBrowserColumns release];

    // Release non-UI outlets that were set in IB.  The window is
    // self-releasing, so we don't release UI outlets.
    [_subtopicListController release];

    [super dealloc];
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
    if (whereTo == nil)
    {
        DIGSLogInfo(@"can't navigate to a nil locator");
        return;
    }
    if ([whereTo topicToDisplay] == nil)
    {
        DIGSLogInfo(@"can't navigate to a nil topic");
        return;
    }

    // Is the topic changing?  (The "!=" check handles nil cases.)
    AKTopic *currentTopic = [whereFrom topicToDisplay];
    AKTopic *newTopic = [whereTo topicToDisplay];
    if ((currentTopic != newTopic) && ![currentTopic isEqual:newTopic])
    {
        NSString *newBrowserPath = [newTopic pathInTopicBrowser];
        if (newBrowserPath == nil)
        {
            DIGSLogInfo(@"couldn't compute new browser path");
            return;
        }

        // Update the topic browser.
        if (![_topicBrowser setPath:newBrowserPath])
        {
            DIGSLogError_ExitingMethodPrematurely(
                ([NSString stringWithFormat:
                    @"can't navigate to browser path [%@]",
                    newBrowserPath]));
            return;
        }

        // Workaround for -setPath: annoyance: make the browser
        // columns as right-justified as possible.
        [[_topicBrowser window] disableFlushWindow];
        [_topicBrowser scrollColumnToVisible:0];
        [_topicBrowser scrollColumnToVisible:[_topicBrowser lastColumn]];
        [[_topicBrowser window] enableFlushWindow];

        // Update the description field.
        NSString *desc = [newTopic stringToDisplayInDescriptionField];
        [_topicDescriptionField setStringValue:desc];
    }

    // Tell my subordinate controllers to navigate, and to modify whereTo
    // if necessary.
    [_subtopicListController navigateFrom:whereFrom to:whereTo];
}

- (void)jumpToSubtopicWithIndex:(NSInteger)subtopicIndex
{
    [_subtopicListController jumpToSubtopicWithIndex:subtopicIndex];
}


#pragma mark -
#pragma mark Action methods

- (IBAction)removeBrowserColumn:(id)sender
{
    NSInteger numColumns = [_topicBrowser maxVisibleColumns];

    if (numColumns > 2)
    {
        [_topicBrowser setMaxVisibleColumns:(numColumns - 1)];
    }
}

- (IBAction)addBrowserColumn:(id)sender
{
    NSInteger numColumns = [_topicBrowser maxVisibleColumns];

    [_topicBrowser setMaxVisibleColumns:(numColumns + 1)];
}

- (IBAction)doBrowserAction:(id)sender
{
    [_windowController jumpToTopic:
        [[_topicBrowser selectedCell] representedObject]];
}


#pragma mark -
#pragma mark AKSubcontroller methods

- (void)doAwakeFromNib
{
    [_topicBrowser setPathSeparator:AKTopicBrowserPathSeparator];
    [_topicBrowser setReusesColumns:NO];
    [_topicBrowser loadColumnZero];
    [_topicBrowser selectRow:1 inColumn:0];  // selects "NSObject"

    [_subtopicListController doAwakeFromNib];
}

- (void)applyUserPreferences
{
    NSString *path = [_topicBrowser path];

    [_topicBrowser loadColumnZero];
    [_topicBrowser setPath:path];
    [_topicBrowser setNeedsDisplay:YES];

    [_subtopicListController applyUserPreferences];
}

- (BOOL)validateItem:(id)anItem
{
    return [_subtopicListController validateItem:anItem];
}


#pragma mark -
#pragma mark NSBrowser delegate methods

- (void)browser:(NSBrowser *)sender createRowsForColumn:(NSInteger)column
    inMatrix:(NSMatrix *)matrix
{
    // Put an upper bound on the font size, because NSBrowser seems to be
    // stubborn about changing its row height.
    NSString *fontName =
        [AKPrefUtils stringValueForPref:AKListFontNamePrefName];
    NSInteger fontSizePref =
        [AKPrefUtils intValueForPref:AKListFontSizePrefName];
    NSInteger fontSize = (fontSizePref > 16) ? 16 : fontSizePref;
    NSFont *font = [NSFont fontWithName:fontName size:fontSize];
    NSInteger numRows = [self _numberOfRowsInColumn:column];

    [matrix setFont:font];
    [matrix renewRows:numRows columns:1];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell
    atRow:(int)row column:(int)column
{
    NSArray *topicList =
        [_topicListsForBrowserColumns objectAtIndex:column];
    AKTopic *topic = [topicList objectAtIndex:row];

    [cell setRepresentedObject:topic];

    [cell setTitle:[topic stringToDisplayInTopicBrowser]];
    [cell setEnabled:[topic browserCellShouldBeEnabled]];
    [cell setLeaf:![topic browserCellHasChildren]];
}

- (BOOL)browser:(NSBrowser *)sender isColumnValid:(int)column
{
    return YES;
}

@end


#pragma mark -
#pragma mark Private methods

@implementation AKTopicBrowserController (Private)

- (NSInteger)_numberOfRowsInColumn:(NSInteger)column
{
    // Defensive programming: see if we are trying to populate a
    // browser column that's too far to the right.
    if (column > (int)[_topicListsForBrowserColumns count])
    {
        DIGSLogError(@"_topicListsForBrowserColumns has too few elements");
        return 0;
    }

    // Discard data for columns we will no longer displaying.
    NSInteger numBrowserColumns = [_topicBrowser lastColumn] + 1;
    if (column > numBrowserColumns)  // gmd
    {
        DIGSLogError(@"_topicListsForBrowserColumns has too few elements /gmd");
        return 0;
    }
    while (numBrowserColumns < (int)[_topicListsForBrowserColumns count])
    {
        [_topicListsForBrowserColumns removeLastObject];
    }

    // Compute browser values for this column if we don't have them already.
    if (column == (int)[_topicListsForBrowserColumns count])
    {
        [self _setUpChildTopics];
        if (column >= (int)[_topicListsForBrowserColumns count]) // gmd
        {
            // This Framework has no additional topics like Functions,
            // Protocols, etc. (happens for PDFKit, PreferencePanes, which
            // just have classes)
            return 0;
        }
    }

    // Now that the data ducks have been lined up, simply pluck our answer
    // from _topicListsForBrowserColumns.
    return [[_topicListsForBrowserColumns objectAtIndex:column] count];
}

- (void)_setUpChildTopics
{
    NSInteger columnNumber = [_topicListsForBrowserColumns count];

    if (columnNumber == 0)
    {
        [self _setUpTopicsForZeroethBrowserColumn];
    }
    else
    {
        AKTopic *prevTopic =
            [[_topicBrowser selectedCellInColumn:(columnNumber - 1)]
                representedObject];
        NSArray *columnValues = [prevTopic childTopics];

        if (columnValues && ([columnValues count] > 0))
        {
            [_topicListsForBrowserColumns addObject:columnValues];
        }
    }
}

// on entry, _topicListsForBrowserColumns must be empty
- (void)_setUpTopicsForZeroethBrowserColumn
{
    NSMutableArray *columnValues = [NSMutableArray array];
    AKDatabase *db = [_windowController database];
    NSEnumerator *classEnum = [[AKSortUtils arrayBySortingArray:[db rootClasses]] objectEnumerator];
    AKClassNode *classNode;

    // Set up the ":: classes ::" section of this browser column.  We want
    // the browser column to list all classes that don't have superclasses.
    [columnValues addObject:[AKLabelTopic topicWithLabel:@":: classes ::"]];

    while ((classNode = [classEnum nextObject]))
    {
        [columnValues addObject:[AKClassTopic topicWithClassNode:classNode]];
    }

    // Set up the ":: other topics ::" section of this browser column.
    // We want the browser column to list all known frameworks.
    [columnValues addObject:[AKLabelTopic topicWithLabel:@":: other topics ::"]];

    NSEnumerator *fwNameEnum = [[db sortedFrameworkNames] objectEnumerator];
    NSString *fwName;

    while ((fwName = [fwNameEnum nextObject]))
    {
        [columnValues addObject:[AKFrameworkTopic topicWithFrameworkNamed:fwName inDatabase:db]];
    }

    [_topicListsForBrowserColumns addObject:columnValues];
}

@end
