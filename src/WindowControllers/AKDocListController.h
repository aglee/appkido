/*
 * AKDocListController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKWindowSubcontroller.h"

@class AKTableView;
@class AKSubtopic;
@class AKDocLocator;
@class AKDocView;
@class AKDoc;

/*!
 * @class       AKDocListController
 * @abstract    Controller for a browser window's list of docs.
 * @discussion  An AKDocListController is one of the subordinate
 *              controller objects owned by an AKWindowController.  It
 *              manages an NSTableView used to list and select docs based
 *              on the window's selected topic and subtopic.  It also
 *              manages a text view used to display the selected doc.
 *
 *              An AKDocListController's list of docs is encapsulated
 *              by an AKSubtopic corresponding to the selected item in
 *              the window's subtopic list.
 */
@interface AKDocListController : AKWindowSubcontroller
{
    // The subtopic whose list of docs we should display.
    AKSubtopic *_subtopicToDisplay;

    // UI outlets.
    IBOutlet AKTableView *_docListTable;
    IBOutlet AKDocView *_docView;
    IBOutlet NSTextField *_docCommentField;
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (void)setSubtopic:(AKSubtopic *)subtopic;

- (AKDoc *)currentDoc;

//-------------------------------------------------------------------------
// Navigation
//-------------------------------------------------------------------------

// may modify whereTo
- (void)navigateFrom:(AKDocLocator *)whereFrom to:(AKDocLocator *)whereTo;

/*!
 * @method      focusOnDocListTable
 * @discussion  Assigns first responder status to the doc list table.
 */
- (void)focusOnDocListTable;

//-------------------------------------------------------------------------
// Action methods
//-------------------------------------------------------------------------

/*!
 * @method      doDocListTableAction:
 * @discussion  Responds to the user's selection of an item in the doc
 *              list table.
 */
- (IBAction)doDocListTableAction:(id)sender;

@end
