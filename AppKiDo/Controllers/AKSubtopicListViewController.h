/*
 * AKSubtopicListViewController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKViewController.h"

@class AKSubtopic;
@class AppKiDoTableView;

/*!
 * Manages the "subtopic list", which lists the subtopics of the window's
 * currently selected topic.
 */
@interface AKSubtopicListViewController : AKViewController <NSTableViewDelegate, NSTableViewDataSource, NSUserInterfaceValidations>

@property (nonatomic, weak) IBOutlet AppKiDoTableView *subtopicsTable;
@property (readonly, strong) AKSubtopic *selectedSubtopic;

#pragma mark - Action methods

- (IBAction)doSubtopicTableAction:(id)sender;

- (IBAction)selectGeneralSubtopic:(id)sender;

- (IBAction)selectHeaderFile:(id)sender;

- (IBAction)selectPropertiesSubtopic:(id)sender;
- (IBAction)selectAllPropertiesSubtopic:(id)sender;

- (IBAction)selectClassMethodsSubtopic:(id)sender;
- (IBAction)selectAllClassMethodsSubtopic:(id)sender;

- (IBAction)selectInstanceMethodsSubtopic:(id)sender;
- (IBAction)selectAllInstanceMethodsSubtopic:(id)sender;

- (IBAction)selectDelegateMethodsSubtopic:(id)sender;
- (IBAction)selectAllDelegateMethodsSubtopic:(id)sender;

- (IBAction)selectNotificationsSubtopic:(id)sender;
- (IBAction)selectAllNotificationsSubtopic:(id)sender;

@end
