//
//  AKDevTools.h
//  AppKiDo
//
//  Created by Andy Lee on 2/11/09.
//  Copyright 2009 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*! Some docsets get installed here for some reason. */
#define AKSharedDocSetDirectory @"/Library/Developer/Shared/Documentation/DocSets"

/*! Xcode 4 puts the docsets here. */
#define AKLibraryDocSetDirectory @"/Library/Developer/Documentation/DocSets"

@class AKDocSetIndex;

/*!
 * Abstract class that represents a Dev Tools installation as it relates to
 * development for a particular platform. At the moment the supported platforms are
 * Mac and iOS, hence the subclasses AKMacDevTools and AKIPhoneDevTools.
 *
 * Within the Dev Tools directory (typically /Developer unless the user chose to
 * install with a different directory name) there are SDK versions (e.g., "10.6",
 * "10.7" for the Mac platform). We associate each SDK version with two directories:
 * a .docset bundle and a headers directory. The data AppKiDo presents to the user
 * comes from these two directories.
 */
@interface AKDevTools : NSObject
{
@private
    NSString *_devToolsPath;
    NSMutableDictionary *_docSetPathsBySDKVersion;
    NSMutableArray *_sdkVersionsThatHaveDocSets;
    NSMutableDictionary *_sdkPathsBySDKVersion;
}


#pragma mark -
#pragma mark Factory methods

/*! devToolsPath is typically /Developer. It's the top-level Dev Tools directory. */
+ (id)devToolsWithPath:(NSString *)devToolsPath;


#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithPath:(NSString *)devToolsPath;


#pragma mark -
#pragma mark Dev Tools paths

/*!
 * Does a rough sanity check on a directory that is claimed to be a Dev Tools directory.
 * Checks for the presence of Xcode and a few other things.
 */
+ (BOOL)looksLikeValidDevToolsPath:(NSString *)devToolsPath errorStrings:(NSMutableArray *)errorStrings;

/*! Typically /Developer, but can be wherever the user has installed the Dev Tools. */
- (NSString *)devToolsPath;


#pragma mark -
#pragma mark Docset paths

/*!
 * Subclasses must override.  Returns the directories in which we look for docsets.
 *
 * Docsets are sometimes outside of the Dev Tools directory. At some point (I forget
 * when) Xcode started installing them in /Library/Developer.
 */
- (NSArray *)docSetSearchPaths;

/*!
 * Subclasses must override.  Checks whether fileName is a valid docset name for
 * the platform we address.
 */
- (BOOL)isValidDocSetName:(NSString *)fileName;

/*! Uses latest version if sdkVersion is nil. */
- (NSString *)docSetPathForSDKVersion:(NSString *)sdkVersion;


#pragma mark -
#pragma mark SDK paths

/*!
 * Subclasses must override.  Returns the directory in which we look for
 * SDKs (special directories whose names end in .sdk).
 */
- (NSString *)sdkSearchPath;

/*! Returns a sorted array of strings in order of version number. */
- (NSArray *)sdkVersionsThatHaveDocSets;

/*!
 * Returns latest version we know of if sdkVersion is nil.  Note that sdkVersion could
 * be something like 3.1 and the returned path could be for something like 3.1.2.
 */
- (NSString *)sdkPathForSDKVersion:(NSString *)sdkVersion;

@end
