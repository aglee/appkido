//
//  AKPlatformConstants.m
//  AppKiDo
//
//  Created by Andy Lee on 6/7/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKPlatformConstants.h"

NSString *AKPlatformInternalNameMac   = @"macosx";
NSString *AKPlatformInternalNameIOS   = @"iphoneos";
NSString *AKPlatformInternalNameWatch = @"watchos";
NSString *AKPlatformInternalNameTV    = @"appletvos";

NSString *AKDisplayNameForPlatformInternalName(NSString *platformInternalName)
{
	static NSDictionary *s_displayNamesByInternalName;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		s_displayNamesByInternalName = @{ AKPlatformInternalNameMac : @"macOS",
										  AKPlatformInternalNameIOS : @"iOS",
										  AKPlatformInternalNameWatch : @"watchOS",
										  AKPlatformInternalNameTV : @"tvOS" };
	});

	return (s_displayNamesByInternalName[platformInternalName]
			?: platformInternalName);
}

