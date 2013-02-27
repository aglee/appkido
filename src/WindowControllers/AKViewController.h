/*
 * AKViewController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import "AKUIController.h"

@class AKDocLocator;
@class AKWindowController;

/*!
 * Base class for view controllers used by AKBrowserWindowController.
 */
@interface AKViewController : NSViewController <AKUIController>
{
@private
    AKWindowController *_owningWindowController;  // weak reference
}

#pragma mark -
#pragma mark Init/dealloc/awake

- (id)initWithNibName:nibName windowController:(AKWindowController *)windowController;

#pragma mark -
#pragma mark Getters and setters

- (AKWindowController *)owningWindowController;

#pragma mark -
#pragma mark Navigation

/*! May modify whereTo. */
- (void)navigateFrom:(AKDocLocator *)whereFrom to:(AKDocLocator *)whereTo;

@end
