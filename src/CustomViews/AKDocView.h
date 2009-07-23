/*
 * AKDocView.h
 *
 * Created by Andy Lee on Thu Sep 02 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <AppKit/AppKit.h>

@class AKDocLocator;
@class WebView;


// [agl] Instead of this, should use a tabless tab view and create an
// AKDocViewController class


@interface AKDocView : NSView
{
    AKDocLocator *_docLocator;

    NSString *_headerFontName;
    int _headerFontSize;
    int _docMagnifier;
    
    // These are used during awakeFromNib to remember where in the window's
    // key view loop we were, because we are going to be modifying the loop
    // whenever we swap subviews in and out, and the loop gets complicated
    // when the subview is a WebView.
    NSView *_originalPreviousKeyView;
    NSView *_originalNextKeyView;

    // At any given time, our one and only subview is either
    // _scrollView or _webView.  Is _webView if WebKit is available, unless
    // we are displaying a header file, in which case we use _scrollView
    // because we want to render plain text without being confused by angle
    // brackets in #import directives.
    NSScrollView *_scrollView;
    WebView *_webView;  // nil if WebKit is not available.

    IBOutlet id _docListController;
}


#pragma mark -
#pragma mark Getters and setters

- (void)setDocLocator:(AKDocLocator *)docLocator;


#pragma mark -
#pragma mark UI behavior

- (void)applyPrefs;

- (NSView *)grabFocus;

@end
