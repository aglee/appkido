/*
 *  AKDocSetIndex.h
 *
 *  Created by Andy Lee on 1/6/08.
 *  Copyright 2008 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

/*!
 * Provides read-only access to the SQLite database of API tokens that Apple
 * started providing with Leopard.  The database is in a file called
 * docSet.dsidx in the documentation directory.
 */
@interface AKDocSetIndex : NSObject
{
@private
    NSString *_docSetPath;  // Path to a .docset bundle.

    // The ZHEADER table contains absolute paths to header files in
    // /System/Library/Frameworks.  However, the files should actually be
    // looked up under the appropriate SDK directory in the Dev Tools.
    // In particular, the iPhone headers exist only under the Dev Tools
    // directory -- there is no /System/Library/Frameworks/UIKit.framework
    // on the Mac, for example.  We need to prefix that path with
    // /(DEVTOOLS)/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator2.0.sdk
    // to find the UIKit headers.  That prefix is was goes in _basePathForHeaders.
    //
    // I *think* I can get away with using the plain /System/Library/Frameworks
    // header paths for the Core Reference docs, so this can be @"/" when
    // the docset is a Core Reference docset.  Otherwise, the tricky thing
    // is that there can be multiple SDKs for regular Mac OS; for example,
    // under /(DEVTOOLS)/SDKs I have MacOSX10.4u.sdk and MacOSX10.5.sdk.
    // I'll assume the user's actual OS will be the latest of these, and
    //  that the documentation is the same for all.
    NSString *_basePathForHeaders;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

/*!
 * Looks for the docset index file at a specific subpath of the Dev Tools
 * path, which so far has always been the same for the Mac OS Core Reference
 * docset.  Returns nil if there is no docset index file at that location.
 */
+ (id)indexForMacSDKInDevToolsPath:(NSString *)devToolsPath;

/*!
 * Returns nil if we can't find an iPhoneSDK...dsIdx file.
 *
 * [agl] FIXME Should we search in the Shared directory as well?
 */
+ (id)indexForLatestIPhoneSDKInDevToolsPath:(NSString *)devToolsPath;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*!
 * Designated initializer.  docSetPath is the path to a .docset bundle
 * (i.e., should end with .docset).  basePathForHeaders is the path to the
 * path that the header paths in the docset index (as given by the sqlite
 * file) should be relative to.
 *
 * Returns nil if the docset path or base path for headers is missing or
 * not a directory.
 */
- (id)initWithDocSetPath:(NSString *)docSetPath
    basePathForHeaders:(NSString *)basePathForHeaders;

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

/*!
 * The doc paths returned by the xxxDocPathsForFramework: methods are relative
 * to this directory.
 */
- (NSString *)baseDirForDocPaths;

/*! 
 * Names of frameworks the user can choose from, with "essential"
 * frameworks forced to the beginning of the list but otherwise in
 * alphabetical order.  (See AKNamesOfEssentialFrameworks.)
 */
- (NSArray *)selectableFrameworkNames;

/*! Returns absolute directories containing header files. */
- (NSSet *)headerDirsForFramework:(NSString *)frameworkName;

/*!
 * Class docs, protocol docs, "FrameworkX ClassY Additions" docs, deprecated
 * method/class docs.  Returns paths (NSStrings) relative to +baseDirForDocPaths.
 */
- (NSArray *)behaviorDocPathsForFramework:(NSString *)frameworkName;

/*! Returns paths (NSStrings) relative to +baseDirForDocPaths. */
- (NSArray *)functionsDocPathsForFramework:(NSString *)frameworkName;

/*! Returns paths (NSStrings) relative to +baseDirForDocPaths. */
- (NSArray *)globalsDocPathsForFramework:(NSString *)frameworkName;

@end
