//
//  AKFocusView.h
//  AppKiDo
//
//  Created by Andy Lee on 3/11/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 * Draws a focus ring if any descendant view is first responder. Automatically
 * redraws as needed, as different views in the window accept and resign first
 * responder.
 *
 * Expects to have exactly one subview, which is sized and positioned so that
 * its edges are slightly inside the AKFocusView. The focus ring is drawn in
 * that thin margin, around the inner view.
 *
 * I created this class partly because I think focus rings look better in a
 * solid color than with Apple's standard fuzzy-blue halo, and partly so that I
 * can draw a focus ring around a WebView, which doesn't have a way to do so
 * otherwise AFAIK.
 */
@interface AKFocusView : NSView
{
@private
    NSWindow *_owningWindow;  // Weak reference.
}

#pragma mark -
#pragma mark Init/awake/dealloc

#pragma mark -
#pragma mark NSView methods

/*!
 * Starts KVO observation of the window's firstResponder (which became
 * KV-Observable in 10.6).
 */
- (void)viewDidMoveToWindow;

@end
