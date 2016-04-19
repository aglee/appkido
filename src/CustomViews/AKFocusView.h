//
//  AKFocusView.h
//  AppKiDo
//
//  Created by Andy Lee on 3/11/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//TODO: Maybe make the focus ring thickness and color settable properties.

//TODO: If drawing performance becomes a problem (e.g., for a complex custom
// view), there are various ways this class could be optimized.  [EDIT: And now I wish I written them down.]

/*!
 * Draws a focus ring if any descendant view is first responder. Automatically
 * redraws as needed, as different views in the window accept and resign first
 * responder, and as the window itself becomes and resigns key window.
 *
 * Should have exactly one subview. Keeps the inner view sized and positioned so
 * that its edges are slightly inside the AKFocusView. The focus ring is drawn
 * in that thin margin, around the inner view.
 *
 * I created this class partly because I think focus rings look better in a
 * solid color than with Apple's standard fuzzy-blue halo, and partly so that I
 * can draw a focus ring around a WebView, which doesn't have a way to do so
 * otherwise AFAIK.
 *
 * Requires 10.6, because that's when NSWindow's firstResponder became
 * KVO-compliant.
 *
 * HOW TO USE
 * ----------
 * Suppose you have a view that you would like to have AKFocusView's custom
 * focus ring. Embed that view, and *only* that view, in an instance of
 * AKFocusView. Don't worry about margins or autoresizing masks; regardless of
 * what you do in IB, AKFocusView hijacks those settings and automatically sizes
 * the inner view so its edges are slightly inside the AKFocusView's edges.
 */
@interface AKFocusView : NSView

@end
