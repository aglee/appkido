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
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)iPhoneDirectoriesWithDevToolsPath:(NSString *)devToolsPath;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*! Designated initializer. */
- (id)initWithDevToolsPath:(NSString *)devToolsPath;

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSString *)docSetsDir;
- (NSString *)sdksDir;

- (NSString *)pathToLatestDocSet;
- (NSString *)pathToLatestHeadersDir;

@end
