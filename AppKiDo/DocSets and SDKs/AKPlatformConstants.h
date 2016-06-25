//
//  AKPlatformConstants.h
//  AppKiDo
//
//  Created by Andy Lee on 6/7/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Platform names -- "internal"

// Used by SDKs in SDKSettings.plist and by docsets in Info.plist.
extern NSString *AKPlatformInternalNameMac;
extern NSString *AKPlatformInternalNameIOS;
extern NSString *AKPlatformInternalNameTV;
extern NSString *AKPlatformInternalNameWatch;

#pragma mark - Platform names -- displayed

// Display names corresponding to the "internal" platform names above.
extern NSString *AKPlatformDisplayNameMac;
extern NSString *AKPlatformDisplayNameIOS;
extern NSString *AKPlatformDisplayNameTV;
extern NSString *AKPlatformDisplayNameWatch;

#pragma mark - Platform names -- converting

/*! Converts an internal name to the corresponding display name. */
extern NSString *AKPlatformDisplayNameForInternalName(NSString *internalName);

/*! Converts a display name to the corresponding internal name. */
extern NSString *AKPlatformInternalNameForDisplayName(NSString *displayName);
