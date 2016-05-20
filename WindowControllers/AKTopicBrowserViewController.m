/*
 * AKTopicBrowserViewController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopicBrowserViewController.h"
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
#import "AKTopic.h"
#import "AKWindowController.h"
#import "AKWindowLayout.h"
#import "DIGSLog.h"

@interface AKTopicBrowserViewController ()
@property (readonly) NSMutableArray *topicArraysForBrowserColumns;
@property (readonly) NSArray *topicsForFirstBrowserColumn;
@end

@implementation AKTopicBrowserViewController

@synthesize topicArraysForBrowserColumns = _topicArraysForBrowserColumns;
@synthesize topicsForFirstBrowserColumn = _topicsForFirstBrowserColumn;

static const NSInteger AKMinBrowserColumns = 2;

#pragma mark - Init/dealloc/awake

- (instancetype)initWithNibName:nibName windowController:(AKWindowController *)windowController
{
	self = [super initWithNibName:nibName windowController:windowController];
	if (self) {
		_topicArraysForBrowserColumns = [[NSMutableArray alloc] init];
		_topicsForFirstBrowserColumn = [self _rootTopics];
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
//[STILL MATRIX-BASED] See note elsewhere in this file about not being able to use item-based delegate.
//	NSIndexPath *indexPath = self.topicBrowser.selectionIndexPath;
//	AKTopic *topic = (AKTopic *)[self.topicBrowser itemAtIndexPath:indexPath];
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
	//[STILL MATRIX-BASED]: Note that setting the font on cellPrototype only
	// works if we use the matrix-based delegate methods.  That's why I haven't
	// switched yet to the item-based methods.
	[self.topicBrowser.cellPrototype setFont:[self _browserFont]];

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

#pragma mark - <NSBrowserDelegate> methods

//[STILL MATRIX-BASED]: This is very annoying.  The browser delegate code could be simplified if I were to switch it to implement the item-based delegate methods.  But when I do that, my old way of changing the browser's font no longer works (setFont: on the cellPrototype), and I haven't found any way that does.
//- (id)rootItemForBrowser:(NSBrowser *)browser
//{
//	return nil;
//}
//
//- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(AKTopic *)item
//{
//	return (item == nil
//			? self.topicsForFirstBrowserColumn.count
//			: item.childTopics.count);
//}
//
//- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(AKTopic *)item
//{
//	return (item == nil
//			? self.topicsForFirstBrowserColumn[index]
//			: item.childTopics[index]);
//}
//
//- (id)browser:(NSBrowser *)browser objectValueForItem:(AKTopic *)item
//{
//	return item.name;
//}
//
//- (BOOL)browser:(NSBrowser *)browser isLeafItem:(AKTopic *)item
//{
//	return (item.childTopics.count == 0);
//}
//
//- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
//{
//	AKTopic *topic = [sender itemAtRow:row inColumn:column];
//	[cell setEnabled:topic.browserCellShouldBeEnabled];
//	[cell setFont:[self _browserFont]];
//}

#pragma mark - <NSBrowserDelegate> methods

//[STILL MATRIX-BASED]: See comments in this file about why I haven't switched to item-based.
- (void)browser:(NSBrowser *)sender createRowsForColumn:(NSInteger)column inMatrix:(NSMatrix *)matrix
{
	[matrix renewRows:[self _numberOfRowsInColumn:column] columns:1];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
	NSArray *topicList = self.topicArraysForBrowserColumns[column];
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

- (NSInteger)_numberOfRowsInColumn:(NSUInteger)columnIndex
{
	// Defensive programming: see if we are trying to populate a
	// browser column that's too far to the right.
	if (columnIndex > self.topicArraysForBrowserColumns.count) {
		DIGSLogError(@"topicArraysForBrowserColumns has too few elements");
		return 0;
	}

	// Discard data for columns we will no longer displaying.
	NSUInteger numBrowserColumns = self.topicBrowser.lastColumn + 1;
	if (columnIndex > numBrowserColumns) {  // gmd
		DIGSLogError(@"topicArraysForBrowserColumns has too few elements /gmd");
		return 0;
	}
	while (numBrowserColumns < self.topicArraysForBrowserColumns.count) {
		[self.topicArraysForBrowserColumns removeLastObject];
	}

	// Compute browser values for this column if we don't have them already.
	if (columnIndex == self.topicArraysForBrowserColumns.count) {
		[self _addArrayOfChildTopics];
		if (columnIndex >= self.topicArraysForBrowserColumns.count) { // gmd
			// This Framework has no additional topics like Functions,
			// Protocols, etc. (happens for PDFKit, PreferencePanes, which
			// just have classes)
			return 0;
		}
	}

	// Now that the data ducks have been lined up, simply pluck our answer
	// from _topicListsForBrowserColumns.
	NSArray *topics = self.topicArraysForBrowserColumns[columnIndex];
	return topics.count;
}

- (void)_addArrayOfChildTopics
{
	NSInteger columnIndex = self.topicArraysForBrowserColumns.count;
	if (columnIndex == 0) {
		[self.topicArraysForBrowserColumns addObject:[self _rootTopics]];
	} else {
		AKTopic *prevTopic = [[self.topicBrowser selectedCellInColumn:(columnIndex - 1)] representedObject];
		NSArray *childTopics = prevTopic.childTopics;
		if (childTopics.count > 0) {
			[self.topicArraysForBrowserColumns addObject:childTopics];
		}
	}
}

// Items in the topic browser's first column.
- (NSArray *)_rootTopics
{
	NSMutableArray *topics = [NSMutableArray array];
	AKDatabase *db = self.owningWindowController.database;

	// Set up the "classes" section.
	[topics addObject:[[AKLabelTopic alloc] initWithLabel:@":: classes ::"]];
	for (AKClassToken *classToken in [AKSortUtils arrayBySortingArray:db.rootClasses]) {
		[topics addObject:[[AKClassTopic alloc] initWithClassToken:classToken]];
	}

	// Set up the "frameworks" section.
	[topics addObject:[[AKLabelTopic alloc] initWithLabel:@":: frameworks ::"]];
	for (AKFramework *fw in db.sortedFrameworks) {
		[topics addObject:[[AKFrameworkTopic alloc] initWithFramework:fw]];
	}

	return topics;
}

- (NSFont *)_browserFont
{
	NSString *fontName = [AKPrefUtils stringValueForPref:AKListFontNamePrefName];
	NSInteger fontSize = [AKPrefUtils intValueForPref:AKListFontSizePrefName];
	return [NSFont fontWithName:fontName size:fontSize];
}

@end
