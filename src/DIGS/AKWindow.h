/*
 * DIGSWindow.h
 *
 * Created by Andy Lee on Wed Apr 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

// [agl] Fill in notes on how to use this class.

// [agl] Have only tested looping chains, not nonlooping.

// [agl] Include toolbar items in the chain when Full Keyboard Access is on.

/*!
 * Implements a key view loop.
 */
@interface AKWindow : NSWindow
{
@private
    NSMutableArray *_loopingTabChains;
    NSMutableArray *_nonloopingTabChains;
}

#pragma mark -
#pragma mark Key view loop, aka tab chain

/*!
 * If the event is Tab or Shift-Tab, returns [self tabToNext] or
 * [self tabToPrevious] accordingly. You can override [NSApplication sendEvent:]
 * to call this.
 */
- (BOOL)maybeHandleTabChainEvent:(NSEvent *)anEvent;

- (void)addLoopingTabChain:(NSArray *)views;

- (void)addNonloopingTabChain:(NSArray *)views;

- (void)removeAllTabChains;

- (BOOL)tabToNext;

- (BOOL)tabToPrevious;

#pragma mark -
#pragma mark Debugging

- (void)debug_printTabChains;

@end
