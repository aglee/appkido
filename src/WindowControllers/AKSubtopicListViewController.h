/*
 * AKSubtopicListViewController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKViewController.h"

@class AKTableView;
@class AK_DocListViewController;
@class AKDocLocator;

/*!
 * Manages the "subtopic list", which displays the subtopics of the window's
 * currently selected topic.
 */
@interface AKSubtopicListViewController : AKViewController
{
@private
    // Elements are instances of AKSubtopic classes.  Order of elements
    // matches order of subtopics listed in _subtopicsTable.  This is a
    // derived attribute based on the window's currently selected topic.
    NSMutableArray *_subtopics;

    // IBOutlets.
    AKTableView *_subtopicsTable;
}

@property (nonatomic, assign) IBOutlet AKTableView *subtopicsTable;

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
