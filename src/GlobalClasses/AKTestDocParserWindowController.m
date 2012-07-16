/*
 * AKTestDocParserWindowController.m
 *
 * Created by Andy Lee on Mon May 09 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKTestDocParserWindowController.h"

#import "AKDocParser.h"
#import "AKFileSection.h"

@implementation AKTestDocParserWindowController

@synthesize filePathField = _filePathField;
@synthesize parseResultTextView = _parseResultTextView;

+ (NSMutableArray *)_testDocParserWindowControllers
{
    static NSMutableArray *_testDocParserWindowControllers = nil;
    
    if (_testDocParserWindowControllers == nil)
    {
        _testDocParserWindowControllers = [[NSMutableArray alloc] init];
    }
    
    return _testDocParserWindowControllers;
}

+ (void)openNewParserWindow
{
    AKTestDocParserWindowController *instance = [[self alloc] initWithWindowNibName:@"TestDocParser"];
    
    [[self _testDocParserWindowControllers] addObject:instance];
    
    [[instance window] makeKeyAndOrderFront:nil];
}

#pragma mark - Action methods

- (IBAction)chooseFileToParse:(id)sender
{
    NSOpenPanel *op = [NSOpenPanel openPanel];
    
    [op setCanChooseFiles:YES];
    [op setCanChooseDirectories:NO];
    [op setAllowsMultipleSelection:NO];
    [op beginSheetForDirectory:nil
                          file:nil
                         types:nil
                modalForWindow:[self window]
                 modalDelegate:self
                didEndSelector:@selector(_openPanelForTestParseDidEnd:returnCode:contextInfo:)
                   contextInfo:NULL];
}

- (IBAction)takeFileToParseFrom:(id)sender
{
    [self _parseFileAtPath:[sender stringValue]];
}

#pragma mark - NSWindowDelegate methods

- (void)windowWillClose:(NSNotification *)notification
{
    if ([notification object] == [self window])
    {
        [[self retain] autorelease];
        [[[self class] _testDocParserWindowControllers] removeObject:self];
    }
}

#pragma mark - Private methods

- (void)_openPanelForTestParseDidEnd:(NSOpenPanel *)sheet
                          returnCode:(int)returnCode
                         contextInfo:(void *)contextInfo
{
    if (returnCode == NSCancelButton)
    {
        return;
    }

    NSString *fileToParse = [[sheet filenames] lastObject];
    
    if (fileToParse)
    {
        [_filePathField setStringValue:fileToParse];
        [self _parseFileAtPath:fileToParse];
    }
}

- (void)_parseFileAtPath:(NSString *)fileToParse
{
    AKDocParser *dp = [[[AKDocParser alloc] initWithFramework:nil] autorelease];
    
    [dp processFile:fileToParse];
    
    NSString *parseResult = [[dp rootSectionOfCurrentFile] descriptionAsOutline];
    
    [_parseResultTextView setString:(parseResult ? parseResult : @"<error>")];
}

@end

