/*
 * AKTestDocParserWindowController.h
 *
 * Created by Andy Lee on Mon May 09 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@interface AKTestDocParserWindowController : NSWindowController
{
    NSTextView *_parseResultTextView;
    NSTextField *_filePathField;
}

@property (assign) IBOutlet NSTextField *filePathField;
@property (assign) IBOutlet NSTextView *parseResultTextView;

+ (void)openNewParserWindow;

- (IBAction)chooseFileToParse:(id)sender;
- (IBAction)takeFileToParseFrom:(id)sender;

@end
