//
//  AKTabChainWindowDelegate.h
//  AppKiDo
//
//  Created by Andy Lee on 3/15/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 * Informal protocol. Messages are sent to the window's delegate by AKTabChain,
 * but the idea is to pretend they're NSWindow delegate methods, as if they were
 * sent by NSWindow.
 */
@protocol AKTabChainWindowDelegate <NSWindowDelegate>

@required

/*!
 * Returns an array of views to cycle through. The first should be the one
 * before which to insert toolbar buttons when Full Keyboard Access is on.
 */
- (NSArray *)tabChainViewsForWindow:(NSWindow *)window;

@optional

/*!
 * The delegate can return proposedKeyView, a key view to use instead of
 * proposedKeyView, or nil to veto the selection altogether.
 */
- (NSView *)tabChainWindow:(NSWindow *)window
            willSelectView:(NSView *)proposedKeyView
                   forward:(BOOL)isGoingForward;

/*!
 * didSelect is NO if makeFirstResponder: failed (e.g. due to validation).
 *
 * keyView may not be the same as proposedKeyView or even in the tab chain at
 * all. For example, it could be a toolbar button.
 */
- (void)tabChainWindow:(NSWindow *)window
         didSelectView:(NSView *)keyView
               forward:(BOOL)wasGoingForward
               success:(BOOL)didSelect;

@end
