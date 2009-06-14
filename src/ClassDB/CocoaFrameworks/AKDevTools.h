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
 * versions, each of which has a name, a docset, and a headers directory.
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

- (NSString *)devToolsPath;

- (NSArray *)sdkVersions;  // Returns a sorted array in order of version number.

- (NSString *)docSetPathForVersion:(NSString *)sdkVersion;  // Uses latest version if sdkVersion is nil.
- (NSString *)headersPathForVersion:(NSString *)sdkVersion;  // Uses latest version if sdkVersion is nil.


#pragma mark -
#pragma mark Validation

/*!
 * Does a rough sanity check on a directory that is claimed to be a
 * Dev Tools directory.
 */
+ (BOOL)looksLikeValidDevToolsPath:(NSString *)devToolsPath;


#pragma mark -
#pragma mark Creating a docset index

- (AKDocSetIndex *)docSetIndexForSDKVersion:(NSString *)sdkVersion;


#pragma mark -
#pragma mark For internal use only

- (NSString *)relativePathToDocSetsDir;  // Subclasses must override.
- (NSString *)relativePathToHeadersDir;  // Subclasses must override.
- (BOOL)isValidDocSetName:(NSString *)fileName;  // Subclasses must override.

@end
