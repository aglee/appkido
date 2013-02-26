/*
 * AKDocView.m
 *
 * Created by Andy Lee on Thu Sep 02 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDocView.h"

#import <WebKit/WebKit.h>
#import "AKTextView.h"
#import "AKPrefUtils.h"
#import "AKTextUtils.h"
#import "AKFileSection.h"
#import "AKDoc.h"
#import "AKDocLocator.h"

@implementation AKDocView

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect]))
    {
        _headerFontName = @"Monaco";
        _headerFontSize = 10;
        _docMagnifier = 100;
    }

    return self;
}

- (void)awakeFromNib
{
    // Set the _scrollView ivar and make it our one and only subview.
    _scrollView = [[NSScrollView alloc] initWithFrame:[self bounds]];
    [_scrollView setHasHorizontalScroller:NO];
    [_scrollView setHasVerticalScroller:YES];
    [_scrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    [self addSubview:_scrollView];

    // Create a text view to be the document view of _scrollView.
    // [agl] can I do this in IB now?  if so, remember *NOT* to release in
    // -dealloc
    AKTextView *textView = [[AKTextView alloc] initWithFrame:[self bounds]];

    [textView setAutoresizingMask:
        (NSViewWidthSizable | NSViewHeightSizable)];
    [textView setEditable:NO];
    [textView setSelectable:YES];
    [textView setImportsGraphics:YES];
    [textView setRichText:YES];
    [textView setDelegate:(id <NSTextViewDelegate>)[[_scrollView window] delegate]];
    [textView setMenu:[self menu]];

    [textView setFrame:[[_scrollView contentView] bounds]];
    [_scrollView setDocumentView:textView];

    // Remove ourselves from the key view loop and splice the text view
    // in our place.
    _originalPreviousKeyView = [self previousKeyView];
    _originalNextKeyView = [self nextKeyView];
    [_originalPreviousKeyView setNextKeyView:textView];
    [textView setNextKeyView:_originalNextKeyView];

    // Create a WebView that will replace _scrollView in the view hierarchy
    // at appropriate times.
    // [agl] can I do this in IB now?  if so, remember *NOT* to release in
    // -dealloc
    _webView = [[WebView alloc] initWithFrame:[_scrollView frame]
                                    frameName:nil
                                    groupName:nil];
    [_webView setAutoresizingMask:[_scrollView autoresizingMask]];
    [_webView setPolicyDelegate:_docListController];
    [_webView setUIDelegate:_docListController];

    // Update ivars with values from user prefs.
    [self applyPrefs];
}

- (void)dealloc
{
    [_docLocator release];
    [_headerFontName release];

    [super dealloc];
}

#pragma mark -
#pragma mark Getters and setters

- (void)setDocLocator:(AKDocLocator *)docLocator
{
    if ([docLocator isEqual:_docLocator])  // handles nil cases [agl] does it?
    {
        return;
    }

    // Standard setter pattern.
    [_docLocator autorelease];
    _docLocator = [docLocator retain];

    // Update the display.
    [self _updateDocDisplay];
}

#pragma mark -
#pragma mark UI behavior

- (void)applyPrefs
{
    if (![[_docLocator docToDisplay] isPlainText])
    {
        NSInteger docMagnifierPref = [AKPrefUtils intValueForPref:AKDocMagnificationPrefName];

        if (_docMagnifier != docMagnifierPref)
        {
            _docMagnifier = docMagnifierPref;
            [self _updateDocDisplay];
        }
    }
    else
    {
        NSString *headerFontNamePref = [AKPrefUtils stringValueForPref:AKHeaderFontNamePrefName];
        NSInteger headerFontSizePref = [AKPrefUtils intValueForPref:AKHeaderFontSizePrefName];
        BOOL headerFontChanged = NO;

        if (![_headerFontName isEqualToString:headerFontNamePref])
        {
            headerFontChanged = YES;

            // Standard setter pattern.
            [_headerFontName autorelease];
            _headerFontName = [headerFontNamePref copy];
        }

        if (_headerFontSize != headerFontSizePref)
        {
            headerFontChanged = YES;

            _headerFontSize = headerFontSizePref;
        }

        if (headerFontChanged)
        {
            [self _updateDocDisplay];
        }
    }
}

- (NSView *)grabFocus
{
    NSView *currentSubview = [self _subview];

    if (currentSubview == _webView)
    {
        return _webView;  // [agl] ??? No call to makeFirstResponder:?
    }
    else
    {
        NSTextView *textView = [(NSScrollView *)currentSubview documentView];

        if ([[textView window] makeFirstResponder:textView])
        {
            return textView;
        }
        else
        {
            return nil;
        }
    }
}

#pragma mark -
#pragma mark NSView methods

// Return YES so we can be part of the key view loop.
- (BOOL)acceptsFirstResponder
{
    return YES;
}

#pragma mark -
#pragma mark Private methods

// Returns our first and only subview, which will be either _scrollView or
// _webView.
- (NSView *)_subview
{
    return [[self subviews] objectAtIndex:0];
}

- (void)_updateDocDisplay
{
    if (_docLocator == nil)
    {
        return;  // [agl] should I empty out the text view?
    }

    //  Figure out what text to display.
    AKDoc *docToDisplay = [_docLocator docToDisplay];
    AKFileSection *fileSection = [docToDisplay fileSection];
    NSString *htmlFilePath = [fileSection filePath];
    NSData *textData = [docToDisplay docTextData];

    // Display the text in either _textView or _webView.  Whichever it
    // is, swap it in as our subview if necessary.
    if ([docToDisplay isPlainText])
    {
        [self _useScrollViewToDisplayPlainText:textData];
    }
    else
    {
        [self _useWebViewToDisplayHTML:textData fromFile:htmlFilePath];
    }

    // If we used _scrollView, clean it up.
    if ([self _subview] == _scrollView)
    {
        // Make extra sure the cursor rects are updated so we get the
        // hand cursor over links.  Note: you'd think we should
        // invalidate the cursor rects for textView, but no, for some
        // reason it doesn't work unless we do it for scrollView.
        [[_scrollView window] invalidateCursorRectsForView:_scrollView];
    
        // For some reason the scroller often thinks the text is longer
        // than it is, so I force a -tile.
        [_scrollView tile];
    }
}

- (void)_useScrollViewToDisplayPlainText:(NSData *)textData
{
    // Make _scrollView our subview if it isn't already.
    NSView *currentSubview = [self _subview];
    NSTextView *textView = [_scrollView documentView];

    if (currentSubview != _scrollView)  // implies currentSubview is _webView
    {
        // Remove _webView from the key view loop.
        id firstResponder = [[self window] firstResponder];
        BOOL wasKey = ([firstResponder isKindOfClass:[NSView class]]
                       && [firstResponder isDescendantOf:_webView]);
        [_originalPreviousKeyView setNextKeyView:_originalNextKeyView];

        // Swap in _scrollView as our subview.
        [_scrollView setFrame:[currentSubview frame]];
        [self replaceSubview:currentSubview with:_scrollView];

        // Splice textView into the key view loop.
        [_originalPreviousKeyView setNextKeyView:textView];
        [textView setNextKeyView:_originalNextKeyView];
        if (wasKey)
        {
            [[self window] makeFirstResponder:textView];
        }
    }

    // Display the plain text in _scrollView.
    NSString *fontName = [AKPrefUtils stringValueForPref:AKHeaderFontNamePrefName];
    NSInteger fontSize = [AKPrefUtils intValueForPref:AKHeaderFontSizePrefName];
    NSFont *plainTextFont = [NSFont fontWithName:fontName size:fontSize];
    NSString *docString = @"";
    
    if (textData)
    {
        docString = [[[NSString alloc] initWithData:textData encoding:NSUTF8StringEncoding] autorelease];
    }

    [textView setRichText:NO];
    [textView setFont:plainTextFont];
// Workaround for appkit bug (?) causing the last-used indentation
// level to stick to the text view even if I clear its contents and
// remove all its attributes.
// [agl] -- but, now it causes assert error?
//    [[textView layoutManager]
//        replaceTextStorage:[[NSTextStorage alloc] initWithString:@""]];

    [textView setString:docString];
    [textView scrollRangeToVisible:NSMakeRange(0, 0)];
}

- (void)_useWebViewToDisplayHTML:(NSData *)htmlData
                        fromFile:(NSString *)htmlFilePath
{
    // Make _webView our subview if it isn't already.
    NSView *currentSubview = [self _subview];
    NSTextView *textView = [_scrollView documentView];

    if (currentSubview != _webView)  // implies currentSubview is _scrollView
    {
        // Remove textView from the key view loop.
        BOOL wasKey = ([[self window] firstResponder] == textView);
        [_originalPreviousKeyView setNextKeyView:_originalNextKeyView];

        // Swap in _webView as our subview.
        [_webView setFrame:[currentSubview frame]];
        [self replaceSubview:currentSubview with:_webView];

        // Splice _webView into the key view loop.
        // [agl] TODO -- the wasKey stuff doesn't work
        [_originalPreviousKeyView setNextKeyView:_webView];
        [_webView setNextKeyView:_originalNextKeyView];
        if (wasKey)
        {
            [[self window] makeFirstResponder:_webView];
        }
    }

    // Apply the user's magnification preference.
    float multiplier = ((float)_docMagnifier) / 100.0f;

    [_webView setTextSizeMultiplier:multiplier];

    // Display the HTML in _webView.
    NSString *htmlString = @"";
    if (htmlData)
    {
        NSMutableData *zData = [NSMutableData dataWithData:htmlData];
        
        [zData setLength:([zData length] + 1)];
        htmlString = [NSString stringWithUTF8String:[zData bytes]];
    }

    if (htmlFilePath)
    {
        [[_webView mainFrame] loadHTMLString:htmlString
                                     baseURL:[NSURL fileURLWithPath:htmlFilePath]];
    }
    else
    {
        [[_webView mainFrame] loadHTMLString:htmlString baseURL:nil];
    }
}

@end
