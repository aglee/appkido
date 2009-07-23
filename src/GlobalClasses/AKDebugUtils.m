/*
 * AKDebugUtils.m
 *
 * Created by Andy Lee on Mon May 09 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKDebugUtils.h"

#import <Cocoa/Cocoa.h>
#import "AKDocParser.h"


#pragma mark -
#pragma mark Category of AKFileSection debugging methods

@implementation AKFileSection (Debugging)

- (void)_printTreeWithDepth:(int)depth
    intoString:(NSMutableString *)s
{
    // Print this section's name at the indicated indentation level.
    int i;
    for (i = 0; i < depth; i++)
    {
        [s appendString:@"  "];
    }
    [s appendString:[self sectionName]];
    [s appendString:
        [NSString stringWithFormat:@" (%d-%d, %d chars)",
            [self sectionOffset],
            [self sectionOffset] + [self sectionLength],
            [self sectionLength]]];
    [s appendString:@"\n"];

    // Print child sections.
    NSEnumerator *en = [self childSectionEnumerator];
    AKFileSection *childSection;
    while ((childSection = [en nextObject]))
    {
        [childSection _printTreeWithDepth:(depth + 1) intoString:s];
    }
}

- (NSMutableString *)_treeAsString
{
    NSMutableString *s = [NSMutableString stringWithCapacity:2000];

    [self _printTreeWithDepth:0 intoString:s];

    return s;
}

@end




#pragma mark -
#pragma mark 

@implementation AKFileSectionDebug

+ (AKFileSectionDebug *)sharedInstance
{
    static AKFileSectionDebug *instance = nil;

    if (instance == nil)
    {
        instance = [[self alloc] init];
    }

    return instance;
}

- (NSWindow *)_windowForTestParse
{
    if (_windowForTestParse == nil)
    {
        int bigWidth = 480;
        int bigHeight = 480;
        NSRect bigFrame = NSMakeRect(50, 50, bigWidth, bigHeight);

        _windowForTestParse =
            [[[NSWindow alloc]
                initWithContentRect:bigFrame
                styleMask:
                    (NSTitledWindowMask
                        | NSClosableWindowMask
                        | NSMiniaturizableWindowMask
                        | NSResizableWindowMask)
                backing:NSBackingStoreBuffered
                defer:NO]
                retain];  // [agl] Am I over-retaining?
        _parseInfoTextView =
            [[[NSTextView alloc]
                initWithFrame:NSMakeRect(10, 10, 10, 10)]  // will be reset
                autorelease];
        _filePathField =
            [[[NSTextField alloc]
                initWithFrame:NSMakeRect(10, 10, 10, 10)]  // will be reset
                autorelease];

        NSView *contentView = [_windowForTestParse contentView];
        NSScrollView *scrollView =
            [[[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, bigWidth, bigHeight - 48)] autorelease];
        NSButton *chooseButton =
            [[[NSButton alloc] initWithFrame:NSMakeRect(10, bigHeight - 40, 200, 18)] autorelease];

        [_windowForTestParse setMinSize:NSMakeSize(bigWidth, bigHeight - 80)];
        [_windowForTestParse setReleasedWhenClosed:NO];

        [chooseButton setTarget:self];
        [chooseButton setAction:@selector(_chooseFileForTestParse:)];
        [chooseButton setBezelStyle:NSRoundedBezelStyle];
        [chooseButton setTitle:@"Select HTML Documentation File..."];
        [chooseButton sizeToFit];
        [chooseButton setAutoresizingMask:(NSViewMaxXMargin | NSViewMinYMargin)];
        NSRect buttonFrame = [chooseButton frame];
        buttonFrame.origin.x = 10;
        [chooseButton setFrame:buttonFrame];

        NSRect textFieldFrame = buttonFrame;
        textFieldFrame.size.width = bigWidth - NSWidth(buttonFrame) - 32;
        textFieldFrame.origin.x = bigWidth - NSWidth(textFieldFrame) - 16;
        [_filePathField setFrame:textFieldFrame];
        [_filePathField setBordered:YES];
        [_filePathField setBezelStyle:NSTextFieldSquareBezel];
        [_filePathField setEditable:NO];
        [_filePathField setSelectable:YES];
        [_filePathField setAutoresizingMask:(NSViewWidthSizable | NSViewMinYMargin)];

        [scrollView setHasHorizontalScroller:YES];
        [scrollView setHasVerticalScroller:YES];
        [scrollView setDocumentView:_parseInfoTextView];
        [scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        [scrollView tile];

        [_parseInfoTextView setFrame:[[scrollView contentView] bounds]];
        [_parseInfoTextView setRichText:NO];
        [_parseInfoTextView setSelectable:YES];
        [_parseInfoTextView setEditable:NO];
        [_parseInfoTextView setFont:[NSFont fontWithName:@"Courier" size:12]];
        [_parseInfoTextView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

        [contentView addSubview:chooseButton];
        [contentView addSubview:_filePathField];
        [contentView addSubview:scrollView];
    }

    return _windowForTestParse;
}

- (IBAction)_chooseFileForTestParse:(id)sender
{
    NSOpenPanel *op = [NSOpenPanel openPanel];

    [op setCanChooseFiles:YES];
    [op setCanChooseDirectories:NO];
    [op setAllowsMultipleSelection:NO];
    [op
        beginSheetForDirectory:nil
        file:nil
        types:nil
        modalForWindow:[self _windowForTestParse]
        modalDelegate:self
        didEndSelector:
            @selector(_openPanelForTestParseDidEnd:returnCode:contextInfo:)
        contextInfo:NULL];
}

- (void)_openPanelForTestParseDidEnd:(NSOpenPanel *)sheet
    returnCode:(int)returnCode
    contextInfo:(void *)contextInfo
{
    if (returnCode == NSCancelButton)
    {
        return;
    }

    NSArray *filenames = [sheet filenames];
    if ([filenames count] == 0)
    {
        return;
    }

    NSString *fname = [filenames objectAtIndex:0];
    AKDocParser *dp = [[[AKDocParser alloc] initWithFramework:nil] autorelease];
    [dp processFile:fname];
    [_filePathField setStringValue:fname];
    [_parseInfoTextView setString:[[dp rootSectionOfCurrentFile] _treeAsString]];
}

- (void)_doTestParse
{
    [[self _windowForTestParse] makeKeyAndOrderFront:nil];
}

+ (void)_testParser
{
    [[self sharedInstance] _doTestParse];
}

@end

