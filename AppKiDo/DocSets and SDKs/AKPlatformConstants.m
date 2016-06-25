//
//  AKPlatformConstants.m
//  AppKiDo
//
//  Created by Andy Lee on 6/7/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKPlatformConstants.h"

#pragma mark - Platform names -- "internal"

NSString *AKPlatformInternalNameMac   = @"macosx";
NSString *AKPlatformInternalNameIOS   = @"iphoneos";
NSString *AKPlatformInternalNameWatch = @"watchos";
NSString *AKPlatformInternalNameTV    = @"appletvos";

#pragma mark - Platform names -- displayed

NSString *AKPlatformDisplayNameMac   = @"macOS";
NSString *AKPlatformDisplayNameIOS   = @"iOS";
NSString *AKPlatformDisplayNameWatch = @"watchOS";
NSString *AKPlatformDisplayNameTV    = @"tvOS";

#pragma mark - Platform names -- converting

NSString *AKPlatformDisplayNameForInternalName(NSString *internalName)
{
	static NSDictionary *s_nameLookup;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		s_nameLookup = @{ AKPlatformInternalNameMac : AKPlatformDisplayNameMac,
						  AKPlatformInternalNameIOS : AKPlatformDisplayNameIOS,
						  AKPlatformInternalNameWatch : AKPlatformDisplayNameWatch,
						  AKPlatformInternalNameTV : AKPlatformDisplayNameTV };
	});
	return (s_nameLookup[internalName] ?: internalName);
}

NSString *AKPlatformInternalNameForDisplayName(NSString *displayName)
{
	static NSDictionary *s_nameLookup;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		s_nameLookup = @{ AKPlatformDisplayNameMac : AKPlatformInternalNameMac,
						  AKPlatformDisplayNameIOS : AKPlatformInternalNameIOS,
						  AKPlatformDisplayNameWatch : AKPlatformInternalNameWatch,
						  AKPlatformDisplayNameTV : AKPlatformInternalNameTV };
	});
	return (s_nameLookup[displayName] ?: displayName);
}

