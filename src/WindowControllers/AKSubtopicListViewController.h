/*
 * AKSubtopicListViewController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKViewController.h"

@class AKSubtopic;
@class AKTableView;

/*!
 * Manages the "subtopic list", which lists the subtopics of the window's
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
#pragma mark Getters and setters

- (AKSubtopic *)selectedSubtopic;

#pragma mark -
#pragma mark Action methods

- (IBAction)doSubtopicTableAction:(id)sender;

- (IBAction)selectSubtopicWithIndexFromTag:(id)sender;

@end
