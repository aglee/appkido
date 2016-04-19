/*
 * AKTestDocParserWindowController.m
 *
 * Created by Andy Lee on Mon May 09 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKTestDocParserWindowController.h"

#import "AKDocParser.h"
#import "AKFileSection.h"

@interface AKTestDocParserWindowController ()
@property (nonatomic, strong) AKFileSection *rootSection;
@end

@implementation AKTestDocParserWindowController

@synthesize rootSection = _rootSection;
@synthesize filePathField = _filePathField;
@synthesize tabView = _tabView;
@synthesize parseResultTextView = _parseResultTextView;
@synthesize parseResultBrowser = _parseResultBrowser;
@synthesize fileSectionTextView = _fileSectionTextView;
@synthesize fileSectionInfoField = _fileSectionInfoField;

static NSMutableArray *_testDocParserWindowControllers = nil;

#pragma mark -
#pragma mark Class initialization

+ (void)initialize
{
    _testDocParserWindowControllers = [[NSMutableArray alloc] init];
}

#pragma mark -
#pragma mark Factory methods

+ (id)openNewParserWindow
{
    AKTestDocParserWindowController *wc;
    wc = [[self alloc] initWithWindowNibName:@"TestDocParser"];

    [wc showWindow:nil];

    return wc;
}

#pragma mark -
#pragma mark Init/dealloc/awake

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self)
    {
        [_testDocParserWindowControllers addObject:self];
    }
    
    return self;
}


#pragma mark -
#pragma mark Parsing

- (void)parseFileAtPath:(NSString *)filePath
{
    [_filePathField setStringValue:filePath];

    AKDocParser *dp = [[AKDocParser alloc] initWithDatabase:nil frameworkName:nil];

    [dp processFile:filePath];

    [self setRootSection:[dp rootSectionOfCurrentFile]];

    NSString *textOutline = [_rootSection descriptionAsOutline];

    [_parseResultTextView setString:(textOutline ?: @"<error>")];
    [_parseResultBrowser loadColumnZero];
}

#pragma mark -
#pragma mark Find Panel support

- (NSView *)viewToSearch
{
    if ([[[_tabView selectedTabViewItem] identifier] isEqualToString:@"outline"])
    {
        return _parseResultTextView;
    }
    else if ([[[_tabView selectedTabViewItem] identifier] isEqualToString:@"browser"])
    {
        return _fileSectionTextView;
    }
    
    return nil;
}

#pragma mark -
#pragma mark Action methods

- (IBAction)chooseFileToParse:(id)sender
{
    NSOpenPanel *op = [NSOpenPanel openPanel];
    
    [op setCanChooseFiles:YES];
    [op setCanChooseDirectories:NO];
    [op setAllowsMultipleSelection:NO];
    
    [op beginSheetModalForWindow:[self window]
               completionHandler:^(NSInteger result) {
                   if (result == NSFileHandlingPanelCancelButton)
                   {
                       return;
                   }

                   NSString *selectedFilePath = [[op URL] path];

                   if (selectedFilePath)
                   {
                       [self parseFileAtPath:selectedFilePath];
                   }
               }];
}

- (IBAction)takeFileToParseFrom:(id)sender
{
    [self parseFileAtPath:[sender stringValue]];
}

- (IBAction)doBrowserAction:(id)sender
{
    NSIndexPath *selectionIndexPath = [_parseResultBrowser selectionIndexPath];
    AKFileSection *fileSection = [_parseResultBrowser itemAtIndexPath:selectionIndexPath];
    NSData *sectionData = [fileSection sectionData];
    NSString *sectionString = [[NSString alloc] initWithData:sectionData
                                                     encoding:NSUTF8StringEncoding];
    [_fileSectionTextView setString:sectionString];
    [_fileSectionInfoField setStringValue:[NSString stringWithFormat:@"%ld-%ld, %ld chars",
                                           (long)[fileSection sectionOffset],
                                           (long)[fileSection sectionOffset] + [fileSection sectionLength],
                                           (long)[fileSection sectionLength]]];
}

#pragma mark -
#pragma mark NSWindowController methods

- (void)windowDidLoad
{
    // If you use IB to set an NSTextView's font, the font doesn't stick,
	// even if you've turned off the text view's richText setting.
    [_parseResultTextView setFont:[NSFont fontWithName:@"Courier" size:13.0]];
    [_fileSectionTextView setFont:[NSFont fontWithName:@"Courier" size:13.0]];
}

#pragma mark -
#pragma mark NSWindowDelegate methods

- (void)windowWillClose:(NSNotification *)notification
{
    if ([notification object] == [self window])
    {
        [_testDocParserWindowControllers removeObject:self];
    }
}

#pragma mark -
#pragma mark NSBrowserDelegate methods

// Note we are using the "item-based" API for NSBrowser.
// <https://developer.apple.com/library/mac/#samplecode/SimpleCocoaBrowser/Listings/AppController_m.html#//apple_ref/doc/uid/DTS40008872-AppController_m-DontLinkElementID_4>

- (id)rootItemForBrowser:(NSBrowser *)browser
{
	return _rootSection;    
}

- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item
{
	return [(AKFileSection *)item numberOfChildSections];
}

- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item
{
	return [(AKFileSection *)item childSectionAtIndex:index];
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item
{
	return ([(AKFileSection *)item numberOfChildSections] == 0);
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item
{
    return [(AKFileSection *)item sectionName];
}

@end
