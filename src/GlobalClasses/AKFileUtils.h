/*
 * AKFileUtils.h
 *
 * Created by Andy Lee on Tue May 10 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

/*!
 * @class       AKFileUtils
 * @discussion  Utility methods that deal with the filesystem.
 */
@interface AKFileUtils : NSObject

//-------------------------------------------------------------------------
// Existence checking
//-------------------------------------------------------------------------

+ (BOOL)directoryExistsAtPath:(NSString *)path;

/*!
 * @method      subdirectoryOf:withName:
 * @discussion  Returns nil if the specified subdirectory doesn't exist.
 */
+ (NSString *)subdirectoryOf:(NSString *)dir
    withName:(NSString *)subdir;

// Returns nil if neither specified subdirectory exists.
/*!
 * @method      subdirectoryOf:withName:
 * @discussion  Returns nil if neither subdirectory exists.
 */
+ (NSString *)subdirectoryOf:(NSString *)dir
    withName:(NSString *)subdir1
    orName:(NSString *)subdir2;

+ (NSString *)subdirectoryOf:(NSString *)dir
    withNameEndingWith:(NSString *)suffix;

@end
