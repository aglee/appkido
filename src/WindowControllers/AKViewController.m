/*
 * AKViewController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKViewController.h"

@implementation AKViewController

#pragma mark -
#pragma mark Init/dealloc/awake

- (id)initWithDefaultNib
{
    return [self init];
}

#pragma mark -
#pragma mark Getters and setters

- (AKWindowController *)browserWindowController
{
    return (AKWindowController *)[[[self view] window] delegate];
}

#pragma mark -
#pragma mark Navigation

- (void)navigateFrom:(AKDocLocator *)whereFrom to:(AKDocLocator *)whereTo
{
}

#pragma mark -
#pragma mark AKUIController methods

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
