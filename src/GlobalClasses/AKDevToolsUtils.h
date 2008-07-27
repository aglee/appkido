/*
 *  AKDevToolsUtils.h
 *
 *  Created by Andy Lee on 1/25/08.
 *  Copyright 2008 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@interface AKDevToolsUtils : NSObject
{
}

//-------------------------------------------------------------------------
// Finding the user's Dev Tools
//-------------------------------------------------------------------------

/*!
 * Tries to run xcode-select -print-path.  If successful, returns the
 * result; otherwise, returns nil.
 */
+ (NSString *)devToolsPathAccordingToXcodeSelect;

@end
