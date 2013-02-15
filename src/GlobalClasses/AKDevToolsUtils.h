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

/*!
 * Returns the result of running
 *
 *      bash -l -c 'echo -n `/usr/bin/xcode-select -print-path`'
 *
 * The reason for using bash -l instead of calling xcode-select directly is that
 * the user can specify a path in DEVELOPER_DIR that supersedes what
 * xcode-select would otherwise return. If for some reason they've set that up
 * in their bash config, I assume that's the path they'd want us to use as the
 * default.
 */
+ (NSString *)pathReturnedByXcodeSelect;

@end
