/*
 * AKApplication.m
 *
 * Created by Andy Lee on Thu Mar 18 2007.
 * Copyright (c) 2003-2007 Andy Lee. All rights reserved.
 */

#import "AKApplication.h"
#import <WebKit/WebKit.h>

@implementation AKApplication

//// Called when the user hits Tab or Shift-Tab. Returns YES if we successfully
//// handled the special case of a web view. WebView does weird things with
//// next- and previousKeyView. For AppKiDo's purposes, we want to make it behave
//// like a "normal" view.
//- (BOOL)_handleTabWithForwardFlag:(BOOL)goingForward
//{
//    // If first responder isn't a view, do nothing.
//    NSResponder *firstResponder = [[self keyWindow] firstResponder];
//    if (![firstResponder isKindOfClass:[NSView class]])
//    {
//        return NO;
//    }
//
//    // If we aren't tabbing out of an WebView, do nothing.
//    WebView *webView = [(NSView *)firstResponder ak_enclosingViewOfClass:[WebView class]];
//    if (webView == nil)
//    {
//        return NO;
//    }
//
//    // Try to go to the next or previous key view of the web view.
//    NSView *viewToGoTo = (goingForward
//                          ? [webView nextValidKeyView]
//                          : [webView previousValidKeyView]);
//    if (viewToGoTo != nil)
//    {
//        if (![[viewToGoTo window] makeFirstResponder:viewToGoTo])
//        {
//            return NO;
//        }
//    }
//
//    // If we got this far, we successfully tabbed out of an WebView.
//    return YES;
//}
//
//- (void)sendEvent:(NSEvent *)anEvent
//{
//    // See if this is one of the special cases we want to handle.
//    if (([anEvent type] == NSKeyDown) && ([[anEvent characters] length] > 0))
//    {
//        unichar ch = [[anEvent characters] characterAtIndex:0];
//
//        // I figured out by testing that 25 is the character we get when the
//        // user hits Shift-Tab.
//        if (ch == '\t')
//        {
//            if ([self _handleTabWithForwardFlag:YES])
//            {
//                return;
//            }
//        }
//        else if ((ch == 25) && ([anEvent modifierFlags] & NSShiftKeyMask))
//        {
//            if ([self _handleTabWithForwardFlag:NO])
//            {
//                return;
//            }
//        }
//    }
//
//    // If we got this far, we want the event handled in the default way.
//    [super sendEvent:anEvent];
//}

@end
