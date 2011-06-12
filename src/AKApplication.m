/*
 * AKApplication.m
 *
 * Created by Andy Lee on Thu Mar 18 2007.
 * Copyright (c) 2003-2007 Andy Lee. All rights reserved.
 */

#import "AKApplication.h"

#import <WebKit/WebKit.h>

@implementation AKApplication

// If the first responder is a view with a WebView as an ancestor view, return
// that WebView, otherwise nil.
- (WebView *)_webViewEnclosingFirstResponder
{
    NSWindow *keyWind = [self keyWindow];
    if (keyWind == nil)
        return nil;

    id view = [keyWind firstResponder];
    if (![view isKindOfClass:[NSView class]])
        return nil;

    while (view != nil)
    {
        if ([view isKindOfClass:[WebView class]])
            return view;
        else
            view = [view superview];
    }

    // If we got this far, there is no enclosing WebView.
    return nil;
}

// Called when the user hits Tab.  Returns YES if this method handles the tab,
// NO if we should forward the event to super.
- (BOOL)_handleTab
{
    // If the tab wasn't entered from within a WebView, do nothing.
    WebView *webView = [self _webViewEnclosingFirstResponder];
    if (webView == nil)
        return NO;

    // Go to the nextKeyView of the WebView's superview.
    NSView *nextKeyView = [[webView superview] nextKeyView];
    if (nextKeyView != nil)
    {
        [[nextKeyView window] makeFirstResponder:nextKeyView];
    }
    return YES;
}

// Called when the user hits Shift-Tab.  Returns YES if this method handles
// the backtab, NO if we should forward the event to super.
- (BOOL)_handleBacktab
{
    // If the tab wasn't entered from within a WebView, do nothing.
    WebView *webView = [self _webViewEnclosingFirstResponder];
    if (webView == nil)
        return NO;

    // Go to the previousKeyView of the WebView's superview.
    NSView *previousKeyView = [[webView superview] previousKeyView];
    if (previousKeyView != nil)
        [[previousKeyView window] makeFirstResponder:previousKeyView];
    return YES;
}

- (void)sendEvent:(NSEvent *)anEvent
{
    if (([anEvent type] == NSKeyDown) && ([[anEvent characters] length] > 0))
    {
        unichar ch = [[anEvent characters] characterAtIndex:0];

        // I figured out by testing that 25 is the character we get when the
        // user hits Shift-Tab.
        if (ch == '\t')
        {
            if ([self _handleTab])
                return;
        }
        else if ((ch == 25) && ([anEvent modifierFlags] & NSShiftKeyMask))
        {
            if ([self _handleBacktab])
                return;
        }
    }

    // If we got this far, we want the default key-down behavior.
    [super sendEvent:anEvent];
}

@end
