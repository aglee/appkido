/*
 * AKTestDocParserWindowController.h
 *
 * Created by Andy Lee on Mon May 09 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class AKFileSection;

@interface AKTestDocParserWindowController : NSWindowController
{
    NSTextField *_filePathField;
    NSTabView *_tabView;
    NSTextView *_parseResultTextView;
    NSBrowser *_parseResultBrowser;
    NSTextView *_fileSectionTextView;
    NSTextField *_fileSectionInfoField;
    
    AKFileSection *_rootSection;  // Root section of parse result.
}

@property (assign) IBOutlet NSTextField *filePathField;
@property (assign) IBOutlet NSTabView *tabView;
@property (assign) IBOutlet NSTextView *parseResultTextView;
@property (assign) IBOutlet NSBrowser *parseResultBrowser;
@property (assign) IBOutlet NSTextView *fileSectionTextView;
@property (assign) IBOutlet NSTextField *fileSectionInfoField;

+ (void)openNewParserWindow;

- (NSView *)viewToSearch;  // Enables us to be targeted by the Find panel.

- (IBAction)chooseFileToParse:(id)sender;
- (IBAction)takeFileToParseFrom:(id)sender;
- (IBAction)doBrowserAction:(id)sender;

@end
