/*
 * AKViewController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import "AKUIController.h"

@class AKBrowserWindowController;

/*!
 * Base class for view controllers used by AKBrowserWindowController.
 */
@interface AKViewController : NSViewController <AKUIController>

#pragma mark -
#pragma mark Getters and setters

- (AKBrowserWindowController *)browserWindowController;

@end
