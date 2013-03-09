/*
 * AKFindPanelController.h
 *
 * Uses modifications to TextEdit example code owned and copyrighted by
 * Apple Computer.
 *
 * Created by Andy Lee on Thu May 15 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import "DIGSFindBufferDelegate.h"

/*!
 * Controller for the application-wide Find panel. Uses DIGSFindBuffer.
 */
@interface AKFindPanelController : NSWindowController <DIGSFindBufferDelegate>
{
@private
    // Did we find anything the last time we tried?  Used to decide what
    // to display in _statusTextField.
    BOOL _lastFindWasSuccessful;

    // IBOutlets.
    NSTextField *_findTextField;
    NSButton *_findNextButton;
    NSTextField *_statusTextField;
}

@property (nonatomic, assign) IBOutlet NSTextField *findTextField;
@property (nonatomic, assign) IBOutlet NSButton *findNextButton;
@property (nonatomic, assign) IBOutlet NSTextField *statusTextField;

#pragma mark -
#pragma mark Action methods

- (IBAction)showFindPanel:(id)sender;

- (IBAction)findNextFindString:(id)sender;

- (IBAction)findNextFindStringAndOrderOut:(id)sender;

- (IBAction)findPreviousFindString:(id)sender;

- (IBAction)useSelectionAsFindString:(id)sender;

@end
