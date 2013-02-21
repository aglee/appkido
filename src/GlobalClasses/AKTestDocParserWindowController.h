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
    NSTextField *__unsafe_unretained _filePathField;
    NSTabView *__unsafe_unretained _tabView;
    NSTextView *__unsafe_unretained _parseResultTextView;
    NSBrowser *__unsafe_unretained _parseResultBrowser;
    NSTextView *__unsafe_unretained _fileSectionTextView;
    NSTextField *__unsafe_unretained _fileSectionInfoField;
    
    AKFileSection *_rootSection;  // Root section of parse result.
}

@property (unsafe_unretained) IBOutlet NSTextField *filePathField;
@property (unsafe_unretained) IBOutlet NSTabView *tabView;
@property (unsafe_unretained) IBOutlet NSTextView *parseResultTextView;
@property (unsafe_unretained) IBOutlet NSBrowser *parseResultBrowser;
@property (unsafe_unretained) IBOutlet NSTextView *fileSectionTextView;
@property (unsafe_unretained) IBOutlet NSTextField *fileSectionInfoField;

+ (void)openNewParserWindow;

- (NSView *)viewToSearch;  // Enables us to be targeted by the Find panel.

- (IBAction)chooseFileToParse:(id)sender;
- (IBAction)takeFileToParseFrom:(id)sender;
- (IBAction)doBrowserAction:(id)sender;

@end
