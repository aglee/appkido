/*
 * AK_ViewController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AK_ViewController.h"

@implementation AK_ViewController

- (void)dealloc
{
    NSLog(@"*** %s -- <%@: %p>", __PRETTY_FUNCTION__, [self class], self);
    
    [super dealloc];
}

#pragma mark -
#pragma mark Getters and setters

- (AK_WindowController *)owningWindowController
{
    return (AK_WindowController *)[[[self view] window] delegate];
}

#pragma mark -
#pragma mark AK_UIController methods

- (void)applyUserPreferences
{
    // Do nothing.
}

- (BOOL)validateItem:(id)anItem
{
    return NO;
}

- (void)takeWindowLayoutFrom:(AKWindowLayout *)windowLayout
{
}

- (void)putWindowLayoutInto:(AKWindowLayout *)windowLayout
{
}

@end
