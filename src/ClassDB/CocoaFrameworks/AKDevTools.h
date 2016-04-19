//
//  AKDevTools.h
//  AppKiDo
//
//  Created by Andy Lee on 2/11/09.
//  Copyright 2009 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 * Abstract class that represents an Apple developer tools installation as it
 * relates to development for a particular platform. At the moment the concrete
 * subclasses are AKMacDevTools and AKIPhoneDevTools. Who knows, maybe someday
 * there will be AKWatchOSDevTools and AKAppleTVDevTools.
 *
 * "Old-style" vs. "standalone" Dev Tools
 * ======================================
 * In ancient times, the Dev Tools root directory always had to be /Developer.
 * At some point Apple relaxed this and allowed multiple Dev Tools installations
 * on the same system. You could name the root directories whatever you wanted.
 * AppKiDo refers to such installations as "old-style".
 *
 * In an old-style installation, Xcode.app was in the Applications subdirectory
 * of /Developer. With Xcode 4.3, the directory structure got inverted. Now, the
 * topmost directory is Xcode.app. Most things that were in the old-style
 * /Developer (with Xcode.app being one obvious exception) are now under
 * Xcode.app/Contents/Developer. AppKiDo refers to such installations as
 * "standalone Xcode".
 *
 * The Mac App Store puts Xcode in /Applications, but you can also download it
 * from apple.com and put it wherever you want. You might do this, for example,
 * to install a beta version of the Dev Tools. You can have multiple standalone
 * Xcodes, with different names if you like.
 *
 * The Dev Tools path
 * ==================
 * The devToolsPath method of AKDevTools returns the "Dev Tools directory" or
 * "Dev Tools path". This means /Developer (or whatever you renamed it) for an
 * old-style installation. It means /your-path-to-Xcode.app/Contents/Developer
 * for a standalone Xcode.
 *
 * SDKs and docsets
 * ================
 * A Dev Tools installation contains some number of SDKs. Each SDK lives in its
 * own directory within the Dev Tools directory and is identified by a version
 * string such as "10.8" for the Mac platform or "5.1" for iOS.
 *
 * AppKiDo presents documentation for one specific SDK version. By default this
 * is the latest version available for which a matching docset bundle has been
 * found. The user can choose some other SDK version, as long as a docset has
 * been found for it. AppKiDo parses two sets of files: the headers found in the
 * SDK's directory, and the HTML files in the docset bundle.
 *
 * The location of the docsets has changed over time. AppKiDo looks for them in
 * various places they might be. As of 4.5 (and probably earlier) it looks like
 * Apple has settled on ~/Library/Developer/Shared/Documentation/DocSets as the
 * place where docsets get installed, complete with HTML documentation files.
 * You may notice there are docset bundles inside Xcode.app, but they don't have
 * local HTML files, just links to online docs, so AppKiDo doesn't use those
 * docsets.
 *
 * Historical note
 * ===============
 * In really, really ancient times docsets weren't used at all. The docs were in
 * plain directories under "/Developer/ADC Reference Library". As of Feb 2013
 * AppKiDo no longer supports this documentation structure.
 *
 * [agl] Explain how AppKiDo docset can "cover" an SDK with a slightly different SDK version.
 */
@interface AKDevTools : NSObject
{
@private
    NSString *_devToolsPath;

    // Paths to all docsets we find, both within this Dev Tools installation and
    // in the various shared locations where docsets are installed.
    NSMutableDictionary *_installedDocSetPathsBySDKVersion;

    // Paths to all SDKs we find within this Dev Tools installation.
    NSMutableDictionary *_installedSDKPathsBySDKVersion;
}

#pragma mark -
#pragma mark Factory methods

+ (instancetype)devToolsWithPath:(NSString *)devToolsPath;


#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (instancetype)initWithPath:(NSString *)devToolsPath NS_DESIGNATED_INITIALIZER;


#pragma mark -
#pragma mark Dev Tools paths

/*! Used by looksLikeValidDevToolsPath:errorStrings:. */
+ (NSArray *)expectedSubdirsForDevToolsPath:(NSString *)devToolsPath;

/*!
 * Does a rough sanity check on a directory that is claimed to be a Dev Tools directory.
 * Checks for the presence of various subdirectories.
 */
+ (BOOL)looksLikeValidDevToolsPath:(NSString *)devToolsPath errorStrings:(NSMutableArray *)errorStrings;

/*!
 * For Xcode before 4.3, this is typically but not necessarily /Developer. For
 * Xcode 4.3+, this is typically but not necessarily
 * /Applications/Xcode.app/Contents/Developer.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *devToolsPath;


#pragma mark -
#pragma mark Docset paths

/*!
 * Subclasses must override.  Checks whether fileName is a valid docset name for
 * the platform we address.
 */
- (BOOL)isValidDocSetName:(NSString *)fileName;

- (NSString *)docSetPathForSDKVersion:(NSString *)docSetSDKVersion;


#pragma mark -
#pragma mark SDK paths

/*!
 * Subclasses must override.  Returns the directory in which we look for
 * SDKs (special directories whose names end in .sdk).
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *sdkSearchPath;

/*! Returns a sorted array of strings in order of version number. */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *sdkVersionsThatAreCoveredByDocSets;

/*!
 * Returns latest version we know of if sdkVersion is nil.  Note that sdkVersion could
 * be something like 3.1 and the returned path could be for something like 3.1.2.
 */
- (NSString *)sdkPathForSDKVersion:(NSString *)sdkVersion;


#pragma mark -
#pragma mark SDK versions

- (NSString *)docSetSDKVersionThatCoversSDKVersion:(NSString *)sdkVersion;

@end
