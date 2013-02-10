//
//  AKDevTools.h
//  AppKiDo
//
//  Created by Andy Lee on 2/11/09.
//  Copyright 2009 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*! At some point docsets (at least some of them) started getting installed here. */
#define AKSharedDocSetDirectory @"/Library/Developer/Shared/Documentation/DocSets"

/*! Xcode 4, up to 4.2, puts the docsets here. */
#define AKLibraryDocSetDirectory @"/Library/Developer/Documentation/DocSets"

/*! Starting with Xcode 4.3, this what AppKiDo should use as the Dev Tools directory. */
#define AKDevToolsPathForStandaloneXcode @"/Applications/Xcode.app/Contents/Developer"

/*! Any version of the Xcode tools older than 4.3 is installed here by the package installer. */
#define AKDevToolsPathForOldStyleDevTools @"/Developer"

@class AKDocSetIndex;

// [agl] Long-term, it probably makes sense to get rid of Dev Tools installations as a
// core AppKiDo concept. Instead, there are SDKs in various expected places and there are
// docsets in various expected places. We look for matching SDK/docset pairs (based on
// version number), not Dev Tools installations. I suspect this is how Dash avoids making
// users think about picking one

/*!
 * Abstract class that represents an Apple Dev Tools installation as it relates to
 * development for a particular platform. At the moment the supported platforms are
 * Mac and iOS, hence the subclasses AKMacDevTools and AKIPhoneDevTools.
 *
 * Any given Dev Tools installation supports some set of SDK versions (e.g., "10.6",
 * "10.7" for the Mac platform). AppKiDo associates each supported SDK version with
 * two directories: a docset bundle and a headers directory. The data AppKiDo presents
 * comes from these two directories.
 *
 * Prior to Xcode 4.3, the Dev Tools root directory was /Developer by default, although
 * the user could choose to install elsewhere. Xcode.app was in the Applications
 * subdirectory, and headers for the supported SDKs were in a different subdirectory.
 * Command-line tools were in yet another subdirectory.
 *
 * As of Xcode 4.3, Xcode.app is the Dev Tools root and is installed in /Applications
 * via the Mac App Store. Within the Xcode.app bundle -- specifically, under
 * /Applications/Xcode.app/Contents/Developer -- are other applications and resources
 * including headers for the supported SDKs. A separate installation step puts
 * command-line tools such as git in /usr/bin.
 *
 * Until 4.3, the SDK directories were always under the Dev Tools directory. The docsets,
 * however, have moved around over time, even before 4.3, so AppKiDo looks for them in
 * various places they might be.
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

+ (id)devToolsWithPath:(NSString *)devToolsPath;


#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithPath:(NSString *)devToolsPath;


#pragma mark -
#pragma mark Dev Tools paths

/*! Used by looksLikeValidDevToolsPath:errorStrings:. */
+ (NSArray *)expectedSubdirsForDevToolsPath:(NSString *)devToolsPath;

/*!
 * Does a rough sanity check on a directory that is claimed to be a Dev Tools directory.
 * Checks for the presence of various subdirectories.
 */
+ (BOOL)looksLikeValidDevToolsPath:(NSString *)devToolsPath errorStrings:(NSMutableArray *)errorStrings;

/*! Typically /Developer, but can be wherever the user has installed the Dev Tools. */
- (NSString *)devToolsPath;

+ (NSString *)devToolsPathFromPossibleXcodePath:(NSString *)possibleXcodePath;


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
