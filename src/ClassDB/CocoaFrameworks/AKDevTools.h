//
//  AKDevTools.h
//  AppKiDo
//
//  Created by Andy Lee on 2/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*! Some docsets get installed here for some reason. */
#define AKSharedDocSetDirectory @"/Library/Developer/Shared/Documentation/DocSets"

/*! Xcode4 puts the docsets here. */
#define AKLibraryDocSetDirectory @"/Library/Developer/Documentation/DocSets"

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

/*!
 * Does a rough sanity check on a directory that is claimed to be a Dev Tools directory.
 * Checks for the presence of Xcode and a few other things.
 */
+ (BOOL)looksLikeValidDevToolsPath:(NSString *)devToolsPath errorStrings:(NSMutableArray *)errorStrings;

/*! Typically /Developer, but can be wherever the user has installed the Dev Tools. */
- (NSString *)devToolsPath;


#pragma mark -
#pragma mark Docset paths

/*! Subclasses must override.  Returns the directories in which we look for docsets. */
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
