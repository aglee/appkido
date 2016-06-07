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

/*! Path to a .sdk directory. */
@property (copy, readonly) NSString *basePath;
/*! The platform name Apple uses in plists for docsets and SDKs. */
@property (copy, readonly) NSString *platformInternalName;
@property (copy, readonly) NSString *platformDisplayName;
@property (copy, readonly) NSString *sdkVersion;

#pragma mark - Finding installed SDKs

/*!
 * xcodeAppPath must point to an Xcode application bundle, e.g.
 * "/Applications/Xcode.app".  The returned array is sorted by platform and
 * version.
 */
+ (NSArray *)sdksWithinXcodePath:(NSString *)xcodeAppPath;

#pragma mark - Platform names for display

+ (NSString *)displayNameForPlatformInternalName:(NSString *)platformInternalName;

@end
