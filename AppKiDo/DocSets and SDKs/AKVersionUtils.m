//
//  AKVersionUtils.m
//  AppKiDo
//
//  Created by Andy Lee on 6/7/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKVersionUtils.h"

// Values I've observed in various SDKSettings.plist files:
// - appletvos
// - iphoneos
// - macosx
// - watchos
NSString *AKDisplayNameForPlatformInternalName(NSString *platformInternalName)
{
	static NSDictionary *s_displayNamesByInternalName;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		s_displayNamesByInternalName = @{ @"macosx" : @"OS X",
										  @"iphoneos" : @"iOS",
										  @"watchos" : @"watchOS",
										  @"appletvos" : @"tvOS" };
	});

	return (s_displayNamesByInternalName[platformInternalName]
			?: platformInternalName);
}

