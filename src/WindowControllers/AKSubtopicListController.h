/*
 * AKSubtopicListController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKWindowSubcontroller.h"

@class AKTableView;
@class AKDocListController;
@class AKDocLocator;

/*!
 * @class       AKSubtopicListController
 * @abstract    Controller for a browser window's subtopic list.
 * @discussion  An AKSubtopicListController is one of the subordinate
 *              controller objects owned by an AKWindowController.  It
 *              manages an NSTableView used to list the subtopics of the
 *              window's selected topic.
 */
@interface AKSubtopicListController : AKWindowSubcontroller
{
    // Elements are instances of AKSubtopic classes.  Order of elements
    // matches order of subtopics listed in _subtopicsTable.  This is a
    // derived attribute based on the window's currently selected topic.
    NSMutableArray *_subtopics;

    // Non-UI outlets.
    IBOutlet AKDocListController *_docListController;

    // UI outlets.
    IBOutlet AKTableView *_subtopicsTable;
}


#pragma mark -
#pragma mark Navigation

// may modify whereTo
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
- (void)jumpToSubtopicWithIndex:(int)subtopicIndex;


#pragma mark -
#pragma mark Action methods

/*!
 * @method      doSubtopicTableAction:
 * @discussion  [agl] fill this in
 */
- (IBAction)doSubtopicTableAction:(id)sender;

@end
