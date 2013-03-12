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
        _loopingTabChains = [[NSMutableArray alloc] init];
        _nonloopingTabChains = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [_loopingTabChains release];
    [_nonloopingTabChains release];

    [super dealloc];
}

#pragma mark -
#pragma mark Key view loop, aka tab chain

// I figured out by testing that 25 is the character we get when the
// user hits Shift-Tab.
//
// Recalculates tab chains on every Tab or Shift-Tab, in case something has
// happened recently that would affect the key view loop. For example, the user
// might have switched the Full Keyboard Access flag in System Preferences.
- (BOOL)maybeHandleTabChainEvent:(NSEvent *)anEvent
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
        [(AKWindowController *)[self delegate] recalculateTabChains];

        return [self tabToNext];
    }
    else if ((ch == 25) && ([anEvent modifierFlags] & NSShiftKeyMask))
    {
        [(AKWindowController *)[self delegate] recalculateTabChains];

        return [self tabToPrevious];
    }

    return NO;
}

- (void)addLoopingTabChain:(NSArray *)views
{
    [_loopingTabChains addObject:[NSArray arrayWithArray:views]];
}

- (void)addNonloopingTabChain:(NSArray *)views
{
    [_nonloopingTabChains addObject:[NSArray arrayWithArray:views]];
}

- (void)removeAllTabChains
{
    [_loopingTabChains removeAllObjects];
    [_nonloopingTabChains removeAllObjects];
}

- (BOOL)tabToNext
{
    NSView *currentKeyView = [self _currentKeyView];

    if (currentKeyView == nil)
    {
        return NO;
    }

    for (NSArray *chainOfViews in _loopingTabChains)
    {
        if ([self _goFrom:currentKeyView toNextInChain:chainOfViews looping:YES])
        {
            return YES;
        }
    }

    for (NSArray *chainOfViews in _nonloopingTabChains)
    {
        if ([self _goFrom:currentKeyView toNextInChain:chainOfViews looping:NO])
        {
            return YES;
        }
    }

    return NO;
}

- (BOOL)tabToPrevious
{
    NSView *currentKeyView = [self _currentKeyView];

    if (currentKeyView == nil)
    {
        return NO;
    }

    for (NSArray *chainOfViews in _loopingTabChains)
    {
        if ([self _goFrom:currentKeyView toPreviousInChain:chainOfViews looping:YES])
        {
            return YES;
        }
    }

    for (NSArray *chainOfViews in _nonloopingTabChains)
    {
        if ([self _goFrom:currentKeyView toPreviousInChain:chainOfViews looping:NO])
        {
            return YES;
        }
    }

    return NO;
}

#pragma mark -
#pragma mark NSWindow methods

// As suggested by Gerriet Denkmann.  Protects against nil being passed.
- (void)setTitle:(NSString *)aString
{
	if (aString == nil)
	{
		aString = @"*** nil ***";
	}

	[super setTitle:aString];
}

#pragma mark -
#pragma mark Debugging

- (void)debug_printTabChains
{
    NSLog(@"TAB CHAINS for %@", [self ak_bareDescription]);

    for (NSArray *views in _loopingTabChains)
    {
        NSLog(@"- looping:");
        for (NSView *v in views)
        {
            NSLog(@"    %@", [v ak_bareDescription]);
        }
    }

    for (NSArray *views in _nonloopingTabChains)
    {
        NSLog(@"- nonlooping:");
        for (NSView *v in views)
        {
            NSLog(@"    %@", [v ak_bareDescription]);
        }
    }
    
    NSLog(@"END TAB CHAINS for %@\n\n", [self ak_bareDescription]);
}

#pragma mark -
#pragma mark Private methods

- (NSView *)_currentKeyView
{
    if ([[self firstResponder] isKindOfClass:[NSView class]])
    {
        return (NSView *)[self firstResponder];
    }
    else
    {
        return nil;
    }
    
}

- (BOOL)_goFrom:(NSView *)fromView toNextInChain:(NSArray *)chainOfViews looping:(BOOL)looping
{
    // See if the chain contains the given view.
    NSInteger fromIndex = [self _indexOfViewContainingView:fromView inArray:chainOfViews];

    if (fromIndex == -1)
    {
        return NO;
    }
    
    // Select the next view in the chain, if any, that accepts first responder.
    NSInteger lengthOfChain = [chainOfViews count];
    
    for (NSInteger count = 1; count < lengthOfChain; count++)
    {
        NSInteger viewIndex = fromIndex + count;

        if (viewIndex >= lengthOfChain)
        {
            if (looping)
            {
                viewIndex = 0;
            }
            else
            {
                break;
            }
        }

        NSView *view = [chainOfViews objectAtIndex:viewIndex];

        if ([view acceptsFirstResponder])
        {
            // It's possible for [view window] not to be self -- view could be
            // in a drawer.
            (void)[[view window] makeFirstResponder:view];
            return YES;
        }
    }

    return NO;
}

- (BOOL)_goFrom:(NSView *)fromView toPreviousInChain:(NSArray *)chainOfViews looping:(BOOL)looping
{
    // See if the chain contains the given view.
    NSInteger fromIndex = [self _indexOfViewContainingView:fromView inArray:chainOfViews];

    if (fromIndex == -1)
    {
        return NO;
    }

    // Select the next view in the chain, if any, that accepts first responder.
    NSInteger lengthOfChain = [chainOfViews count];

    for (NSInteger count = 1; count < lengthOfChain; count++)
    {
        NSInteger viewIndex = fromIndex - count;

        if (viewIndex < 0)
        {
            if (looping)
            {
                viewIndex = lengthOfChain - 1;
            }
            else
            {
                break;
            }
        }

        NSView *view = [chainOfViews objectAtIndex:viewIndex];

        if ([view acceptsFirstResponder])
        {
            // It's possible for [view window] not to be self -- view could be
            // in a drawer.
            (void)[[view window] makeFirstResponder:view];
            return YES;
        }
    }
    
    return NO;
}

- (NSInteger)_indexOfViewContainingView:(NSView *)view
                                inArray:(NSArray *)array
{
    NSInteger numViewsInChain = [array count];

    for (NSInteger viewIndex = 0; viewIndex < numViewsInChain; viewIndex++)
    {
        if ([view isDescendantOf:[array objectAtIndex:viewIndex]])
        {
            return viewIndex;
        }
    }

    NSLog(@"%@ is not in the tab chain", [view ak_bareDescription]);
    return -1;
}

@end
