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
 * Base class for view controllers used by AKWindowController.
 */
@interface AKViewController : NSViewController <AKUIController>
{
@private
//ARC    AKWindowController *_owningWindowController;  // weak reference
    __unsafe_unretained AKWindowController *_owningWindowController;  // weak reference
}

@property (nonatomic, readonly, unsafe_unretained) AKWindowController *owningWindowController;

#pragma mark -
#pragma mark Init/dealloc/awake

- (id)initWithNibName:nibName windowController:(AKWindowController *)windowController;

#pragma mark -
#pragma mark Navigation

/*! May modify whereTo. */
- (void)goFromDocLocator:(AKDocLocator *)whereFrom toDocLocator:(AKDocLocator *)whereTo;

@end
