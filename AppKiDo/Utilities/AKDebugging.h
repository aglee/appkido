//
//  AKDebugging.h
//  AppKiDo
//
//  Created by Andy Lee on 2/28/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AKDebugging : NSResponder

#pragma mark - Factory methods

+ (AKDebugging *)sharedInstance;

#pragma mark - Initial setup

+ (BOOL)userCanDebug;

- (void)addDebugMenu;

#pragma mark - Action methods

- (IBAction)printDatabase:(id)sender;

- (IBAction)printFirstResponder:(id)sender;

- (IBAction)printModifiedTabChain:(id)sender;
- (IBAction)printUnmodifiedTabChain:(id)sender;

/*! Logs the current key view loop to the console, using nextValidKeyView. */
- (IBAction)printValidKeyViewLoop:(id)sender;

/*! Logs the current key view loop to the console, using nextKeyView. */
- (IBAction)printEntireKeyViewLoop:(id)sender;

- (IBAction)printFunWindowFacts:(id)sender;

@end
