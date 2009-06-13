//
//  AKIPhoneDirectories.h
//  AppKiDo
//
//  Created by Andy Lee on 2/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 * Encapsulates the logic for finding docsets and SDK directories for the
 * iPhone.  Create an instance specifying where the Dev Tools root is.
 * Then you can ask what docset versions and SDK versions are available,
 * and what the relevant paths are.
 */
@interface AKIPhoneDirectories : NSObject
{
@private
    NSString *_devToolsPath;
    NSMutableArray *_sdkVersions;
    NSMutableDictionary *_docSetPathsByVersion;
    NSMutableDictionary *_headersPathsByVersion;
}


#pragma mark -
#pragma mark Factory methods

+ (id)iPhoneDirectoriesWithDevToolsPath:(NSString *)devToolsPath;


#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithDevToolsPath:(NSString *)devToolsPath;


#pragma mark -
#pragma mark Getters and setters

- (NSString *)devToolsPath;

/*! Returns an array sorted naturally for version strings, i.e., the last indicates the latest version. */
- (NSArray *)sdkVersions;

- (NSString *)docSetPathForVersion:(NSString *)sdkVersion;
- (NSString *)headersPathForVersion:(NSString *)sdkVersion;

- (NSString *)docSetPathForLatestVersion;
- (NSString *)headersPathForLatestVersion;

@end
