/*
 * DIGSWindow.m
 *
 * Created by Andy Lee on Wed Apr 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKWindow.h"
#import "DIGSLog.h"
#import "AKWindowController.h"
#import "NSObject+AppKiDo.h"

@implementation AKWindow

#pragma mark -
#pragma mark Init/dealloc

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)aStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)deferCreation
{
    self = [super initWithContentRect:contentRect
                            styleMask:aStyle
                              backing:bufferingType
                                defer:deferCreation];
    if (self)
    {
        _tabChain = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [_tabChain release];

    [super dealloc];
}

#pragma mark -
#pragma mark Key view loop, aka tab chain

+ (BOOL)isTabChainEvent:(NSEvent *)anEvent forward:(BOOL *)forwardFlagPtr
{
    if ([anEvent type] != NSKeyDown)
    {
        return NO;
    }

    if ([[anEvent characters] length] == 0)
    {
        return NO;
    }

    unichar ch = [[anEvent characters] characterAtIndex:0];

    if (ch == '\t')
    {
        if (forwardFlagPtr)
        {
            *forwardFlagPtr = YES;
        }

        return YES;
    }
    
    // I figured out empirically that 25 is the character we get when the user
    // hits Shift-Tab. Note: the test for modifier flags is not perfect; it
    // returns true if other modifier keys are down in *addition* to Shift.
    if ((ch == 25) && ([anEvent modifierFlags] & NSShiftKeyMask))
    {
        if (forwardFlagPtr)
        {
            *forwardFlagPtr = NO;
        }

        return YES;
    }

    return NO;
}

- (BOOL)handlePossibleTabChainEvent:(NSEvent *)anEvent
{
    BOOL isGoingForward;
    
    if (![[self class] isTabChainEvent:anEvent forward:&isGoingForward])
    {
        return NO;
    }
    
    return (isGoingForward
            ? [self selectNextViewInTabChain]
            : [self selectPreviousViewInTabChain]);
}

- (void)setTabChain:(NSArray *)views
{
    [_tabChain setArray:views];
}

- (BOOL)selectNextViewInTabChain
{
    return [self _tabOutOfCurrentKeyViewMaybeForward:YES];
}

- (BOOL)selectPreviousViewInTabChain
{
    return [self _tabOutOfCurrentKeyViewMaybeForward:NO];
}

#pragma mark -
#pragma mark Debugging

- (void)printTabChain
{
    NSLog(@"TAB CHAIN for %@", [self ak_bareDescription]);

    for (NSView *v in _tabChain)
    {
        NSLog(@"  %@", [v ak_bareDescription]);
    }

    NSLog(@"END TAB CHAINS for %@\n\n", [self ak_bareDescription]);
}

#pragma mark -
#pragma mark NSWindow methods

// As suggested by Gerriet Denkmann.  Protects against crashing due to nil.
- (void)setTitle:(NSString *)aString
{
	if (aString == nil)
	{
		aString = @"*** nil ***";
	}

	[super setTitle:aString];
}

#pragma mark -
#pragma mark Private methods

- (BOOL)_tabOutOfCurrentKeyViewMaybeForward:(BOOL)isGoingForward
{
    // See if the tab chain contains the given view.
    NSInteger currentIndex = [self _indexInTabChainOfViewContainingCurrentKeyView];

    if (currentIndex == -1)
    {
        return NO;
    }
    
    // Select the next view in the chain, if any, that accepts first responder.
    NSInteger lengthOfChain = [_tabChain count];
    
    for (NSInteger count = 1; count < lengthOfChain; count++)
    {
        NSInteger viewIndex = (isGoingForward
                               ? ((currentIndex + count) % lengthOfChain)
                               : ((currentIndex - count + lengthOfChain) % lengthOfChain));
        NSView *view = [_tabChain objectAtIndex:viewIndex];

        if ([view acceptsFirstResponder]
            && [view frame].size.width > 0
            && [view frame].size.height > 0)
        {
            // It's possible for [view window] not to be self -- view could be
            // in a drawer.
            (void)[[view window] makeFirstResponder:view];
            return YES;
        }
    }

    return NO;
}

- (NSInteger)_indexInTabChainOfViewContainingCurrentKeyView
{
    NSView *currentKeyView = (NSView *)[self firstResponder];

    if (![currentKeyView isKindOfClass:[NSView class]])
    {
        return -1;
    }
    
    NSInteger lengthOfChain = [_tabChain count];

    for (NSInteger viewIndex = 0; viewIndex < lengthOfChain; viewIndex++)
    {
        if ([currentKeyView isDescendantOf:[_tabChain objectAtIndex:viewIndex]])
        {
            return viewIndex;
        }
    }

    return -1;
}

@end
