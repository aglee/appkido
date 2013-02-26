/*
 * AK_SubtopicListViewController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AK_ViewController.h"

@class AKTableView;
@class AK_DocListViewController;
@class AKDocLocator;

/*!
 * @class       AK_SubtopicListViewController
 * @abstract    Controller for a browser window's subtopic list.
 * @discussion  An AK_SubtopicListViewController is one of the subordinate
 *              controller objects owned by an AKWindowController.  It
 *              manages an NSTableView used to list the subtopics of the
 *              window's selected topic.
 */
@interface AK_SubtopicListViewController : AK_ViewController
{
@private
    // Elements are instances of AKSubtopic classes.  Order of elements
    // matches order of subtopics listed in _subtopicsTable.  This is a
    // derived attribute based on the window's currently selected topic.
    NSMutableArray *_subtopics;

    // Non-UI outlets.
    IBOutlet AK_DocListViewController *_docListController;

    // UI outlets.
    IBOutlet AKTableView *_subtopicsTable;
}

#pragma mark -
#pragma mark Navigation

/*! May modify whereTo. */
- (void)navigateFrom:(AKDocLocator *)whereFrom to:(AKDocLocator *)whereTo;

/*!
 * @method      jumpToSubtopicWithIndex:
 * @discussion  Navigates to the subtopic at the specified index within
 *   the subtopics table.  Tries to preserve the already-selected doc
 *   name, if the new subtopic has it in its doc list.
 *
 *   This method is mainly to simplify implementation of the various
 *   menu items that navigate to Class Method, Instance Methods, etc.
 */
- (void)jumpToSubtopicWithIndex:(NSInteger)subtopicIndex;

#pragma mark -
#pragma mark Action methods

- (IBAction)doSubtopicTableAction:(id)sender;

@end
