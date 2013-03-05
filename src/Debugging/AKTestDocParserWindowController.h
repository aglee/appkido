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
    NSTextField *_filePathField;
    NSTabView *_tabView;
    NSTextView *_parseResultTextView;
    NSBrowser *_parseResultBrowser;
    NSTextView *_fileSectionTextView;
    NSTextField *_fileSectionInfoField;
}

@property (nonatomic, assign) IBOutlet NSTextField *filePathField;
@property (nonatomic, assign) IBOutlet NSTabView *tabView;
@property (nonatomic, assign) IBOutlet NSTextView *parseResultTextView;
@property (nonatomic, assign) IBOutlet NSBrowser *parseResultBrowser;
@property (nonatomic, assign) IBOutlet NSTextView *fileSectionTextView;
@property (nonatomic, assign) IBOutlet NSTextField *fileSectionInfoField;

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
