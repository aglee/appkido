/*
 * AKViewController.m
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKViewController.h"

@implementation AKViewController

- (void)dealloc
{
    NSLog(@"*** %s -- <%@: %p>", __PRETTY_FUNCTION__, [self class], self);
    
    [super dealloc];
}

#pragma mark -
#pragma mark Getters and setters

- (AKBrowserWindowController *)browserWindowController
{
    return (AKBrowserWindowController *)[[[self view] window] delegate];
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
