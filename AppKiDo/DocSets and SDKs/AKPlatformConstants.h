//
//  AKPlatformConstants.h
//  AppKiDo
//
//  Created by Andy Lee on 6/7/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

// These are the values I've observed in various SDKSettings.plist files.  The
// same internal platform names are used in the Info.plist files in docsets.
extern NSString *AKPlatformInternalNameMac;
extern NSString *AKPlatformInternalNameIOS;
extern NSString *AKPlatformInternalNameTV;
extern NSString *AKPlatformInternalNameWatch;

/*! Converts an internal name to the corresponding marketing name. */
extern NSString *AKDisplayNameForPlatformInternalName(NSString *platformInternalName);
