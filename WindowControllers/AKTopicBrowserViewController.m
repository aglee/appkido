/*
 * AKTopicBrowserViewController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopicBrowserViewController.h"
#import "AKBrowser.h"
#import "AKClassToken.h"
#import "AKClassTopic.h"
#import "AKDatabase.h"
#import "AKDocLocator.h"
#import "AKFrameworkTopic.h"
#import "AKLabelTopic.h"
#import "AKPrefUtils.h"
#import "AKProtocolToken.h"
#import "AKSortUtils.h"
#import "AKSubtopicListViewController.h"
#import "AKWindowController.h"
#import "AKWindowLayout.h"
#import "DIGSLog.h"

@implementation AKTopicBrowserViewController

static const NSInteger AKMinBrowserColumns = 2;

#pragma mark - Init/dealloc/awake

- (instancetype)initWithNibName:nibName windowController:(AKWindowController *)windowController
{
	self = [super initWithNibName:@"TopicBrowserView" windowController:windowController];
	if (self) {
		_topicListsForBrowserColumns = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)awakeFromNib
{
	self.topicBrowser.pathSeparator = AKTopicBrowserPathSeparator;
	self.topicBrowser.reusesColumns = NO;
	[self.topicBrowser loadColumnZero];
	[self.topicBrowser selectRow:1 inColumn:0];  // Row 0 contains a label, so can't be selected.
}

#pragma mark - Action methods

- (IBAction)addBrowserColumn:(id)sender
{
	self.topicBrowser.maxVisibleColumns++;
}

- (IBAction)removeBrowserColumn:(id)sender
{
	if (self.topicBrowser.maxVisibleColumns > AKMinBrowserColumns) {
		self.topicBrowser.maxVisibleColumns--;
	}
}

- (IBAction)doBrowserAction:(id)sender
{
	AKTopic *topic = (AKTopic *)[self.topicBrowser.selectedCell representedObject];
	[self.owningWindowController selectTopic:topic];
}

#pragma mark - AKViewController methods

- (void)goFromDocLocator:(AKDocLocator *)whereFrom toDocLocator:(AKDocLocator *)whereTo
{
	// Handle cases where there's nothing to do.
	if ([whereFrom isEqual:whereTo]) {
		return;
	}

	if (whereTo == nil) {
		DIGSLogInfo(@"can't navigate to a nil locator");
		return;
	}

	if (whereTo.topicToDisplay == nil) {
		DIGSLogInfo(@"can't navigate to a nil topic");
		return;
	}

	// Is the topic changing?  (The "!=" check handles nil cases.)
	AKTopic *currentTopic = whereFrom.topicToDisplay;
	AKTopic *newTopic = whereTo.topicToDisplay;
	if ((currentTopic != newTopic) && ![currentTopic isEqual:newTopic]) {
		NSString *newBrowserPath = [newTopic pathInTopicBrowser];
		if (newBrowserPath == nil) {
			DIGSLogInfo(@"couldn't compute new browser path");
			return;
		}

		// Update the topic browser.
		if (![self.topicBrowser setPath:newBrowserPath]) {
			DIGSLogError_ExitingMethodPrematurely(([NSString stringWithFormat:
													@"can't navigate to browser path [%@]",
													newBrowserPath]));
			return;
		}

		// Workaround for -setPath: annoyance: make the browser
		// columns as right-justified as possible.
		[self.topicBrowser.window disableFlushWindow];  //TODO: Still needed?
		[self.topicBrowser scrollColumnToVisible:0];
		[self.topicBrowser scrollColumnToVisible:self.topicBrowser.lastColumn];
		[self.topicBrowser.window enableFlushWindow];
	}
}

#pragma mark - AKUIController methods

- (void)applyUserPreferences
{
	// You'd think since NSBrowser is an NSControl, you could send it setFont:
	// directly, but no.
	NSString *fontName = [AKPrefUtils stringValueForPref:AKListFontNamePrefName];
	NSInteger fontSize = [AKPrefUtils intValueForPref:AKListFontSizePrefName];
	NSFont *font = [NSFont fontWithName:fontName size:fontSize];
	[self.topicBrowser.cellPrototype setFont:font];

	// Make the browser redraw to reflect its new display attributes.
	NSString *savedPath = self.topicBrowser.path;
	[self.topicBrowser loadColumnZero];
	[self.topicBrowser setPath:savedPath];
}

- (void)takeWindowLayoutFrom:(AKWindowLayout *)windowLayout
{
	if (windowLayout == nil) {
		return;
	}

	// Restore the number of browser columns.
	if (windowLayout.numberOfBrowserColumns) {
		self.topicBrowser.maxVisibleColumns = windowLayout.numberOfBrowserColumns;
	} else {
		self.topicBrowser.maxVisibleColumns = 3;
	}
}

- (void)putWindowLayoutInto:(AKWindowLayout *)windowLayout
{
	if (windowLayout == nil) {
		return;
	}
	windowLayout.numberOfBrowserColumns = self.topicBrowser.maxVisibleColumns;
}

#pragma mark - NSUserInterfaceValidations methods

- (BOOL)validateUserInterfaceItem:(id)anItem
{
	SEL itemAction = [anItem action];

	if (itemAction == @selector(addBrowserColumn:)) {
		return (self.view.frame.size.height > 0.0);
	} else if (itemAction == @selector(removeBrowserColumn:)) {
		return ((self.view.frame.size.height > 0.0)
				&& (self.topicBrowser.maxVisibleColumns > AKMinBrowserColumns));
	} else {
		return NO;
	}
}

#pragma mark - NSBrowser delegate methods

- (void)browser:(NSBrowser *)sender createRowsForColumn:(NSInteger)column inMatrix:(NSMatrix *)matrix
{
	[matrix renewRows:[self _numberOfRowsInColumn:column] columns:1];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
	NSArray *topicList = _topicListsForBrowserColumns[column];
	AKTopic *topic = topicList[row];

	if ([topic name] == nil) {
		NSLog(@"+++ ???");
	}

	[cell setRepresentedObject:topic];
	[cell setTitle:topic.name];
	[cell setEnabled:topic.browserCellShouldBeEnabled];
	[cell setLeaf:(topic.childTopics.count == 0)];
}

- (BOOL)browser:(NSBrowser *)sender isColumnValid:(NSInteger)column
{
	return YES;
}

#pragma mark - Private methods

- (NSInteger)_numberOfRowsInColumn:(NSInteger)column
{
	// Defensive programming: see if we are trying to populate a
	// browser column that's too far to the right.
	if (column > (int)_topicListsForBrowserColumns.count) {
		DIGSLogError(@"_topicListsForBrowserColumns has too few elements");
		return 0;
	}

	// Discard data for columns we will no longer displaying.
	NSInteger numBrowserColumns = self.topicBrowser.lastColumn + 1;
	if (column > numBrowserColumns) {  // gmd
		DIGSLogError(@"_topicListsForBrowserColumns has too few elements /gmd");
		return 0;
	}
	while (numBrowserColumns < (int)_topicListsForBrowserColumns.count) {
		[_topicListsForBrowserColumns removeLastObject];
	}

	// Compute browser values for this column if we don't have them already.
	if (column == (int)_topicListsForBrowserColumns.count) {
		[self _setUpChildTopics];
		if (column >= (int)_topicListsForBrowserColumns.count) { // gmd
			// This Framework has no additional topics like Functions,
			// Protocols, etc. (happens for PDFKit, PreferencePanes, which
			// just have classes)
			return 0;
		}
	}

	// Now that the data ducks have been lined up, simply pluck our answer
	// from _topicListsForBrowserColumns.
	return [_topicListsForBrowserColumns[column] count];
}

- (void)_setUpChildTopics
{
	NSInteger columnNumber = _topicListsForBrowserColumns.count;

	if (columnNumber == 0) {
		[self _setUpTopicsForZeroethBrowserColumn];
	} else {
		AKTopic *prevTopic = [[self.topicBrowser selectedCellInColumn:(columnNumber - 1)] representedObject];
		NSArray *columnValues = [prevTopic childTopics];

		if (columnValues.count > 0) {
			[_topicListsForBrowserColumns addObject:columnValues];
		}
	}
}

// On entry, _topicListsForBrowserColumns must be empty. The items in the
// zeroeth column are in two sections: "classes" (root classes), and
// "other topics" (list of frameworks so that we can navigate to things like
// functions and protocols).
- (void)_setUpTopicsForZeroethBrowserColumn
{
	NSMutableArray *columnValues = [NSMutableArray array];
	AKDatabase *db = self.owningWindowController.database;

	// Set up the "classes" section.
	[columnValues addObject:[[AKLabelTopic alloc] initWithLabel:@":: classes ::"]];
	for (AKClassToken *classToken in [AKSortUtils arrayBySortingArray:db.rootClasses]) {
		[columnValues addObject:[[AKClassTopic alloc] initWithClassToken:classToken]];
	}

	// Set up the "frameworks" section.
	[columnValues addObject:[[AKLabelTopic alloc] initWithLabel:@":: frameworks ::"]];
	for (AKFramework *fw in db.sortedFrameworks) {
		[columnValues addObject:[[AKFrameworkTopic alloc] initWithFramework:fw]];
	}

	[_topicListsForBrowserColumns addObject:columnValues];
}

@end
