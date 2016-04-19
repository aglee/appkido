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
    AKFileSection *_rootSection;  // Root section of parse result.

    // IBOutlets.
    NSTextField *__weak _filePathField;
    NSTabView *__weak _tabView;
    NSTextView *__unsafe_unretained _parseResultTextView;
    NSBrowser *__weak _parseResultBrowser;
    NSTextView *__unsafe_unretained _fileSectionTextView;
    NSTextField *__weak _fileSectionInfoField;
}

@property (nonatomic, weak) IBOutlet NSTextField *filePathField;
@property (nonatomic, weak) IBOutlet NSTabView *tabView;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *parseResultTextView;
@property (nonatomic, weak) IBOutlet NSBrowser *parseResultBrowser;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView *fileSectionTextView;
@property (nonatomic, weak) IBOutlet NSTextField *fileSectionInfoField;

#pragma mark -
#pragma mark Factory methods

+ (id)openNewParserWindow;

#pragma mark -
#pragma mark Parsing

- (void)parseFileAtPath:(NSString *)filePath;

#pragma mark -
#pragma mark Find Panel support

- (NSView *)viewToSearch;  // Enables us to be targeted by the Find panel.

#pragma mark -
#pragma mark Action methods

- (IBAction)chooseFileToParse:(id)sender;
- (IBAction)takeFileToParseFrom:(id)sender;
- (IBAction)doBrowserAction:(id)sender;

@end
