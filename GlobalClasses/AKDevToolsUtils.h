/*
 *  AKDevToolsUtils.h
 *
 *  Created by Andy Lee on 1/25/08.
 *  Copyright 2008 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@interface AKDevToolsUtils : NSObject

/*! Returns the result of running /usr/bin/xcode-select -print-path. */
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
