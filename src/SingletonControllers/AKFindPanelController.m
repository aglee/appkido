/*
 * AKFindPanelController.m
 *
 * Modification of TextEdit code owned and copyrighted by Apple Computer.
 *
 * Created by Andy Lee on Thu May 15 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFindPanelController.h"

#import <WebKit/WebKit.h>

#import "DIGSFindBuffer.h"

#import "AKAppDelegate.h"
#import "AKTestDocParserWindowController.h"
#import "AKTextUtils.h"
#import "AKWindowController.h"

@implementation AKFindPanelController

@synthesize findTextField = _findTextField;
@synthesize findNextButton = _findNextButton;
@synthesize statusTextField = _statusTextField;

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self)
    {
        [[DIGSFindBuffer sharedInstance] addDelegate:self];
    }

    return self;
}

- (void)dealloc
{
    [[DIGSFindBuffer sharedInstance] removeDelegate:self];

    [super dealloc];
}

#pragma mark -
#pragma mark Action methods

- (IBAction)showFindPanel:(id)sender
{
    [self showWindow:nil];
    [_findTextField selectText:nil];
}

- (IBAction)findNextFindString:(id)sender
{
    if (_findTextField)
    {
        [[DIGSFindBuffer sharedInstance] setFindString:[_findTextField stringValue]];
    }
    [self _findWithForwardFlag:YES];
}

- (IBAction)findNextFindStringAndOrderOut:(id)sender
{
    [_findNextButton performClick:nil];

    if (_lastFindWasSuccessful)
    {
        [[_findTextField window] orderOut:sender];
    }
    else
    {
        [_findTextField selectText:nil];
    }
}

- (IBAction)findPreviousFindString:(id)sender
{
    if (_findTextField)
    {
        [[DIGSFindBuffer sharedInstance] setFindString:[_findTextField stringValue]];
    }
    [self _findWithForwardFlag:NO];
}

- (IBAction)useSelectionAsFindString:(id)sender
{
    NSResponder *firstResponder = [[NSApp mainWindow] firstResponder];
    NSString *selection = nil;

    if ([firstResponder isKindOfClass:[NSTextView class]])
    {
        NSTextView *textView = (NSTextView *)firstResponder;
        selection = [[textView string] substringWithRange:[textView selectedRange]];
    }
    else if ([firstResponder isKindOfClass:[NSView class]])
    {
        for (NSView *view = (NSView *)firstResponder; view != nil; view = [view superview])
        {
            if ([view isKindOfClass:[WebView class]])
            {
                // Note that ak_stripHTML can have a newline at the end
                // of its result, even if the user's selected text doesn't
                // end with a newline.  This happens, for example, if the
                // selected text is in the middle of a <pre> element.
                selection = [[[(WebView *)view selectedDOMRange] markupString] ak_stripHTML];
                
                break;
            }

            view = [view superview];
        }
    }

    if (selection)
    {
        [[DIGSFindBuffer sharedInstance] setFindString:[selection ak_trimWhitespace]];
    }
}

#pragma mark -
#pragma mark DIGSFindBufferDelegate methods

- (void)findBufferDidChange:(DIGSFindBuffer *)findBuffer
{
    [_findTextField setStringValue:[findBuffer findString]];
}

#pragma mark -
#pragma mark NSWindowController methods

- (void)windowDidLoad
{
    [_findTextField setStringValue: [[DIGSFindBuffer sharedInstance] findString]];
}

#pragma mark -
#pragma mark Private methods

- (NSView *)_viewToSearch
{
    id windowDelegate = [[NSApp mainWindow] delegate];
    
    if ([windowDelegate isKindOfClass:[AKWindowController class]])
    {
        return [(AKWindowController *)windowDelegate docView];
    }
    else if ([windowDelegate isKindOfClass:[AKTestDocParserWindowController class]])
    {
        return [(AKTestDocParserWindowController *)windowDelegate viewToSearch];
    }
                
    return nil;
}

// Does a find in the whatever view it makes sense to do the find in, if any.
// Selects the found range or beeps if not found.  Sets _lastFindWasSuccessful
// and the status field accordingly.
- (void)_findWithForwardFlag:(BOOL)isForwardDirection
{
    NSWindow *windowToSearch = [NSApp mainWindow];
    id oldFirstResponder = [windowToSearch firstResponder];
    NSView *viewToSearch = [self _viewToSearch];
    
    if (viewToSearch == nil)
    {
        return;
    }
    
    _lastFindWasSuccessful = NO;

    if ([viewToSearch isKindOfClass:[WebView class]])
    {
        NSString *findString = [[DIGSFindBuffer sharedInstance] findString];

        _lastFindWasSuccessful = [(WebView *)viewToSearch searchFor:findString
                                                          direction:isForwardDirection
                                                      caseSensitive:NO
                                                               wrap:YES];
    }
    else if ([viewToSearch isKindOfClass:[NSTextView class]])
    {
        _lastFindWasSuccessful = [self _findInTextView:(NSTextView *)viewToSearch
                                               forward:isForwardDirection];
    }

    if (_lastFindWasSuccessful)
    {
        [_statusTextField setStringValue:@""];
        [[viewToSearch window] makeKeyAndOrderFront:nil];
    }
    else
    {
        NSBeep();
        [_statusTextField setStringValue:@"Not found"];
        (void)[windowToSearch makeFirstResponder:oldFirstResponder];
    }
}

- (BOOL)_findInTextView:(NSTextView *)textView forward:(BOOL)isForwardDirection
{
    NSString *textContents = [textView string];

    if ([textContents length] == 0)
    {
        return NO;
    }

    unsigned searchOptions = NSCaseInsensitiveSearch;

    if (!isForwardDirection)
    {
        searchOptions |= NSBackwardsSearch;
    }

    NSString *findString = [[DIGSFindBuffer sharedInstance] findString];
    NSRange range = [textContents ak_findString:findString
                                  selectedRange:[textView selectedRange]
                                        options:searchOptions
                                           wrap:YES];
    if (range.length == 0)
    {
        return NO;
    }
    else
    {
        [textView setSelectedRange:range];
        [textView scrollRangeToVisible:range];
        (void)[[textView window] makeFirstResponder:textView];
        return YES;
    }
}

@end
