/*
 * DIGSWindow.h
 *
 * Created by Andy Lee on Wed Apr 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

// [agl] Fill in notes on how to the tab chain stuff works.
// * specify array of views
// * uses isDescendantOf:
// * need to override NSApplication's sendEvent:

// [agl] Automatically include toolbar items in the chain when Full Keyboard Access is on.
// Right now I'm doing it manually in AKWindowController.

// [agl] Move the tab chain stuff into an NSObject class, so apps can use whatever window class they want.

/*!
 * Implements a key view loop.
 */
@interface AKWindow : NSWindow
{
@private
    NSMutableArray *_tabChain;  // Elements are NSView.
}

#pragma mark -
#pragma mark Key view loop, aka tab chain

+ (BOOL)isTabChainEvent:(NSEvent *)anEvent forward:(BOOL *)forwardFlagPtr;

/*!
 * You can override [NSApplication sendEvent:] to check for a Tab or Shift-Tab
 * keyboard event (+isTabChainEvent:forward: is provided as a convenience for
 * doing this), and if so to call this method.
 */
- (BOOL)handlePossibleTabChainEvent:(NSEvent *)anEvent;

- (void)setTabChain:(NSArray *)views;

- (BOOL)selectNextViewInTabChain;

- (BOOL)selectPreviousViewInTabChain;

#pragma mark -
#pragma mark Debugging

- (void)printTabChain;

@end
