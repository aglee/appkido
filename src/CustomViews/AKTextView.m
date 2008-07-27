/*
 * AKTextView.m
 *
 * Created by Andy Lee on Thu Mar 18 2007.
 * Copyright (c) 2003-2007 Andy Lee. All rights reserved.
 */

#import "AKTextView.h"

@implementation AKTextView

//-------------------------------------------------------------------------
// NSView methods
//-------------------------------------------------------------------------

- (void)insertTab:(id)sender
{
    NSView *nextKeyView = [self nextKeyView];
    if (nextKeyView != nil)
        [[nextKeyView window] makeFirstResponder:[self nextKeyView]];
}

- (void)insertBacktab:(id)sender
{
    NSView *previousKeyView = [self previousKeyView];
    if (previousKeyView != nil)
        [[previousKeyView window] makeFirstResponder:[self previousKeyView]];
}

@end
