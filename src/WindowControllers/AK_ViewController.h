/*
 * AK_ViewController.h
 *
 * Created by Andy Lee on Tue Jul 30 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import "AK_UIController.h"

@class AK_WindowController;

/*!
 * Base class for view controller objects under AK_WindowController.
 */
@interface AK_ViewController : NSViewController <AK_UIController>

#pragma mark -
#pragma mark Getters and setters

- (AK_WindowController *)owningWindowController;

@end
