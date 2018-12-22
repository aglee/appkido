/*
 * AKDocListViewController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKViewController.h"

@class AppKiDoTableView;
@class AKSubtopic;
@class AKDocLocator;
@class AKDocView;
@class AKDoc;

/*!
 * Manages the "doc list", which lists the docs of the window's currently
 * selected subtopic.
 */
@interface AKDocListViewController : AKViewController <NSTableViewDelegate, NSTableViewDataSource, NSUserInterfaceValidations>
{
@private
	// The subtopic whose list of docs we should display.
	AKSubtopic *_subtopic;

	// IBOutlets.
	AppKiDoTableView *__weak _docListTable;
}

@property (nonatomic, strong) AKSubtopic *subtopic;
@property (nonatomic, weak) IBOutlet AppKiDoTableView *docListTable;

#pragma mark - Getters and setters

@property (readonly, copy) NSString *docComment;

#pragma mark - Navigation

/*! Makes the doc list table first responder. */
- (void)focusOnDocListTable;

#pragma mark - Action methods

/*! Called when the user select an item in the doc list table. */
- (IBAction)doDocListTableAction:(id)sender;

@end
