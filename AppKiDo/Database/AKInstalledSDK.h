//
//  AKInstalledSDK.h
//  AppKiDo
//
//  Created by Andy Lee on 6/3/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * Contains information about an installed SDK, including its base path and the
 * contents of its SDKSettings.plist.
 *
 * SDKs live inside the Xcode application bundle, at subpaths that look like
 * "Contents/Developer/Platforms/XYZ.platform/Developer/SDKs/XYZ.sdk".
 *
 * In addition to the XYZ.sdk directories there may exist directories of the
 * form "XYZversion.sdk", e.g. "WatchOS2.2.sdk".  Sometimes those are symlinks
 * to XYZ.sdk, which seems odd; I'd have expected the symlinks to point in the
 * other direction.  The exception is MacOSX10.11.sdk, which is not a symlink.
 * (This is in Xcode 7.3.1.)
 */
@interface AKInstalledSDK : NSObject

@property (copy, readonly) NSString *basePath;
/*!
 * Values I've observed: "appletvos", "iphoneos", "macosx", "watchos".  These
 * seem to be the same as the possible values for the "DocSetPlatformVersion"
 * key in the Info.plist files of docsets.
 */
@property (copy, readonly) NSString *platform;
@property (copy, readonly) NSString *version;
@property (copy, readonly) NSString *displayName;

#pragma mark - Finding installed SDKs

/*!
 * xcodeAppPath must point to an Xcode application bundle, e.g.
 * "/Applications/Xcode.app".  The returned array is sorted by platform and
 * version.
 */
+ (NSArray *)sdksWithinXcodePath:(NSString *)xcodeAppPath;

@end
