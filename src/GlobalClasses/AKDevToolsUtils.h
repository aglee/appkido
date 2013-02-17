/*
 *  AKDevToolsUtils.h
 *
 *  Created by Andy Lee on 1/25/08.
 *  Copyright 2008 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@interface AKDevToolsUtils : NSObject

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

/*!
 * Tries to derive a path to an existing Dev Tools directory from a path to an
 * Xcode app bundle.
 *
 * Checks whether one of two paths exists on the filesystem:
 * [xcodeAppPath]/Contents/Developer (in which case we return this path) or
 * SOMEPATH/Applications/[xcodeAppPath] (in which case we return SOMEPATH).
 *
 * If neither path exists, we return nil.
 */
+ (NSString *)devToolsPathFromXcodeAppPath:(NSString *)xcodeAppPath;

/*!
 * If given a path to a .app, assumes it's an Xcode app bundle and returns the
 * Dev Tools directory implied by that path. Otherwise assumes the path is
 * already a Dev Tools directory and returns it unmodified.
 */
+ (NSString *)devToolsPathFromPossibleXcodePath:(NSString *)possibleXcodePath;

/*!
 * Tries to derive a path to an existing Xcode app bundle from a Dev Tools path.
 *
 * If devToolsPath matches the pattern
 * SOMEPATH/SOMETHING.app/Contents/Developer, and if SOMEPATH/SOMETHING.app
 * exists on the filesystem, returns SOMEPATH/SOMETHING.app.
 *
 * Otherwise, if [devToolsPath]/Applications/SOMETHING.app/Contents/MacOS/Xcode
 * exists on the filesystem, returns [devToolsPath]/Applications/SOMETHING.app.
 *
 * Otherwise, returns nil.
 */
+ (NSString *)xcodeAppPathFromDevToolsPath:(NSString *)devToolsPath;

@end
