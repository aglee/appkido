//
//  AKDevTools.h
//  AppKiDo
//
//  Created by Andy Lee on 2/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AKDocSetIndex;

/*!
 * Abstract class that represents a Dev Tools installation as it relates to
 * development for a particular platform.  Within the Dev Tools there are SDK
 * versions, each of which has a name (e.g., "3.2" for the iPhone SDK), a
 * docset (given by a path to a .docset bundle), and a headers directory.
 *
 * Concrete subclasses are for Mac and iPhone Dev Tools.
 */
@interface AKDevTools : NSObject
{
@private
    NSString *_devToolsPath;
    NSMutableArray *_sdkVersions;
    NSMutableDictionary *_docSetPathsByVersion;
    NSMutableDictionary *_headersPathsByVersion;
}


#pragma mark -
#pragma mark Factory methods

+ (id)devToolsWithPath:(NSString *)devToolsPath;


#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithPath:(NSString *)devToolsPath;


#pragma mark -
#pragma mark Getters and setters

/*! Typically /Developer, but can be wherever the user has installed the Dev Tools. */
- (NSString *)devToolsPath;

/*! Returns a sorted array of strings in order of version number. */
- (NSArray *)sdkVersions;  // TODO: Maybe better name would be "docVersions".

/*! Uses latest version if sdkVersion is nil. */
- (NSString *)docSetPathForVersion:(NSString *)sdkVersion;

/*!
 * Uses latest version if sdkVersion is nil.  Note that sdkVersion could be something
 * like 3.1 and the returned path could be the headers for something like 3.1.2.
 */
- (NSString *)headersPathForVersion:(NSString *)sdkVersion;


#pragma mark -
#pragma mark Validation

/*!
 * Does a rough sanity check on a directory that is claimed to be a Dev Tools directory.
 * Checks for the presence of Xcode and a few other things.
 */
+ (BOOL)looksLikeValidDevToolsPath:(NSString *)devToolsPath;


#pragma mark -
#pragma mark For internal use only

/*!
 * Subclasses must override.  Returns a relative path within the Dev Tools directory
 * to the directory containing docsets.  Note that docsets can also live outside the
 * Dev Tools directory, in /Library/Developer/Shared/Documentation/DocSets.  For
 * example, the iPhone 3.1 docset now gets installed there for some reason.
 */
- (NSString *)_relativePathToDocSetsDir;

/*!
 * Subclasses must override.  Returns a relative path within the Dev Tools directory
 * to the "SDKs" directory.
 */
- (NSString *)_relativePathToSDKsDir;

/*!
 * Subclasses must override.  Checks whether fileName is a valid docset name for
 * the platform we address.
 */
- (BOOL)_isValidDocSetName:(NSString *)fileName;

@end
