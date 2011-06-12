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
#import "AKTextUtils.h"
#import "AKAppController.h"
#import "AKWindowController.h"


#pragma mark -
#pragma mark Forward declarations of private methods

@interface AKFindPanelController (Private)
- (BOOL)_find:(BOOL)isForwardDirection;
- (void)_findStringDidChange:(DIGSFindBuffer *)findWatcher;
@end

@implementation AKFindPanelController


#pragma mark -
#pragma mark Factory methods

static AKFindPanelController *s_sharedInstance = nil;

+ (AKFindPanelController *)sharedInstance
{
    if (!s_sharedInstance)
    {
        s_sharedInstance = [[self alloc] init];
    }

    return s_sharedInstance;
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)init
{
    if (s_sharedInstance)
    {
        [self release];
        return s_sharedInstance;
    }

    if ((self = [super init]))
    {
        [[DIGSFindBuffer sharedInstance]
            addListener:self
            withSelector:@selector(_findStringDidChange:)];

        s_sharedInstance = self;
    }

    return self;
}

- (void)awakeFromNib
{
    [_findTextField setStringValue:
        [[DIGSFindBuffer sharedInstance] findString]];
}

- (void)dealloc
{
    if (self != s_sharedInstance)
    {
        [[DIGSFindBuffer sharedInstance] removeListener:self];

        [super dealloc];
    }
}


#pragma mark -
#pragma mark Action methods

- (IBAction)orderFrontFindPanel:(id)sender
{
    [_findTextField selectText:nil];
    [[_findTextField window] makeKeyAndOrderFront:nil];
}

- (IBAction)findNextAndOrderFindPanelOut:(id)sender
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

- (IBAction)findNext:(id)sender
{
    if (_findTextField)
    {
        [[DIGSFindBuffer sharedInstance]
            setFindString:[_findTextField stringValue]];
    }
    (void)[self _find:YES];
}

- (IBAction)findPrevious:(id)sender
{
    if (_findTextField)
    {
        [[DIGSFindBuffer sharedInstance]
            setFindString:[_findTextField stringValue]];
    }
    (void)[self _find:NO];
}

- (IBAction)takeFindStringFromSelection:(id)sender
{
    id fr = [[NSApp keyWindow] firstResponder];

    if ([fr isKindOfClass:[NSTextView class]])
    {
        NSTextView *textView = (NSTextView *)fr;
        NSString *selection =
            [[textView string] substringWithRange:[textView selectedRange]];

        [[DIGSFindBuffer sharedInstance]
            setFindString:[selection ak_trimWhitespace]];
    }
    else if ([fr isKindOfClass:[NSView class]])
    {
        NSView *view = (NSView *)fr;

        while (view)
        {
            if ([view isKindOfClass:[WebView class]])
            {
                WebView *webView = (WebView *)view;
                NSString *selection =
                    [[[webView selectedDOMRange] markupString]
                        ak_stripHTML];

                // Note that ak_stripHTML can have a newline at the end
                // of its result, even if the user's selected text doesn't
                // end with a newline.  This happens, for example, if the
                // selected text is in the middle of a <pre> element.
                [[DIGSFindBuffer sharedInstance]
                    setFindString:[selection ak_trimWhitespace]];

                break;
            }

            // Prepare for next loop iteration.
            view = [view superview];
        }
    }
}

@end


#pragma mark -
#pragma mark Private methods

@implementation AKFindPanelController (Private)

// Does a find in the whatever text view it makes sense to do the find in,
// if any.  Selects the found range or beeps if not found.  Sets the status
// field accordingly.
- (BOOL)_find:(BOOL)isForwardDirection
{
    NSWindow *mainWindow = [NSApp mainWindow];
    id oldFirstResponder = [mainWindow firstResponder];
    AKAppController *appController = [NSApp delegate];
    AKWindowController *wc = [appController frontmostWindowController];
    NSView *viewToSearch = [wc focusOnDocView];

    _lastFindWasSuccessful = NO;

    if (viewToSearch == nil)
    {
        // Do nothing
    }
    else if([viewToSearch isKindOfClass:[WebView class]])
    {
        NSString *findString = [[DIGSFindBuffer sharedInstance] findString];

        _lastFindWasSuccessful =
            [(WebView *)viewToSearch
                searchFor:findString
                direction:isForwardDirection
                caseSensitive:NO
                wrap:YES];
    }
    else if([viewToSearch isKindOfClass:[NSTextView class]])
    {
        NSTextView *textView = (NSTextView *)viewToSearch;
        NSString *textContents = [textView string];
        NSString *findString =
            [[DIGSFindBuffer sharedInstance] findString];

        if ([textContents length])
        {
            NSRange range;
            unsigned options = NSCaseInsensitiveSearch;

            if (!isForwardDirection)
            {
                options |= NSBackwardsSearch;
            }

            range = [textContents ak_findString:findString selectedRange:[textView selectedRange] options:options wrap:YES];

            if (range.length)
            {
                [textView setSelectedRange:range];
                [textView scrollRangeToVisible:range];
                _lastFindWasSuccessful = YES;
            }
        }
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
        (void)[mainWindow makeFirstResponder:oldFirstResponder];
    }

    return _lastFindWasSuccessful;
}

- (void)_findStringDidChange:(DIGSFindBuffer *)findWatcher
{
    [_findTextField setStringValue:[findWatcher findString]];
}

@end
