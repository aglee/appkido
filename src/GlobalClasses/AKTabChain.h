//
//  AKTabChain.h
//  AppKiDo
//
//  Created by Andy Lee on 3/15/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

// [agl] convenience method to auto-generate tab chain array

// [agl] event tap so don't have to hack NSApplication?

// [agl] Write the class comment!

// [agl] some way to auto-add buttons etc. when Full Keyboard Access instead of making delegate be aware and have outlets to every button?

// [agl] auto-skip buttons etc. if Full Keyboard Access off, so delegate doesn't have to be aware?

// [agl] argh, one thing I didn't think of: tabbing to select links -- setTabToLinks:

@interface AKTabChain : NSObject

#pragma mark -
#pragma mark Event handling

+ (BOOL)handlePossibleTabChainEvent:(NSEvent *)anEvent;

+ (BOOL)stepThroughTabChainInWindow:(NSWindow *)keyWindow
                            forward:(BOOL)isGoingForward;

+ (NSArray *)unmodifiedTabChainForWindow:(NSWindow *)window;
+ (NSArray *)modifiedTabChainForWindow:(NSWindow *)window;

@end
