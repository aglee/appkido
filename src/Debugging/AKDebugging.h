//
//  AKDebugging.h
//  AppKiDo
//
//  Created by Andy Lee on 2/28/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AKDebugging : NSResponder

#pragma mark -
#pragma mark Factory methods

+ (AKDebugging *)sharedInstance;

#pragma mark -
#pragma mark Initial setup

+ (BOOL)userCanDebug;

- (void)addDebugMenu;

#pragma mark -
#pragma mark Action methods

/*! Opens a window in which you can select a doc file and see it parsed. */
- (IBAction)testParser:(id)sender;

- (IBAction)printFirstResponder:(id)sender;

/*! Logs the current key view loop to the console, using nextValidKeyView. */
- (IBAction)printValidKeyViewLoop:(id)sender;

/*! Logs the current key view loop to the console, using nextKeyView. */
- (IBAction)printEntireKeyViewLoop:(id)sender;

- (IBAction)printViewsOfInterest:(id)sender;

@end
