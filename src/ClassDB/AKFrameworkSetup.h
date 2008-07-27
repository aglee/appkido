//
//  AKFrameworkSetup.h
//  AppKiDo
//
//  Created by Andy Lee on 4/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AKFramework;

@interface AKFrameworkSetup : NSObject
{
    // Elements are AKFrameworks.
    NSMutableArray *_availableFrameworks;
    
    // Elements are NSStrings.
    NSMutableArray *_namesOfAvailableFrameworks;
    
    // Keys are framework names, values are AKFrameworks.
    NSMutableDictionary *_availableFrameworksByName;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

/*!
 * Returns an instance that has been initialized with values in the user's
 * prefs, or nil if the prefs aren't valid.
 */
+ (id)frameworkSetupBasedOnPrefs;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*!
 * Initializes the receiver using various user prefs that specify where
 * documentation and headers are located, and for which frameworks.
 *
 * Returns nil if the AKDevToolsPathPrefName pref has not been set or
 * is invalid.  A dev tools location is invalid if it doesn't seem to
 * contain Core Reference documentation, either in the pre-Leopard
 * directory structure or in a Leopard-style docset database.
 */
- (id)init;

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSArray *)availableFrameworks;
- (NSArray *)namesOfAvailableFrameworks;
- (AKFramework *)frameworkNamed:(NSString *)fwName;

@end
