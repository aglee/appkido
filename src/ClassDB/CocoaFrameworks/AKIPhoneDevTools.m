//
//  AKIPhoneDevTools.m
//  AppKiDo
//
//  Created by Andy Lee on 2/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AKIPhoneDevTools.h"
#import "AKTextUtils.h"


@implementation AKIPhoneDevTools

#pragma mark -
#pragma mark AKDevTools methods

- (NSString *)_relativePathToDocSetsDir
{
    return @"Platforms/iPhoneOS.platform/Developer/Documentation/DocSets/";
}

- (NSString *)_relativePathToSDKsDir
{
    return @"Platforms/iPhoneOS.platform/Developer/SDKs/";
}

- (BOOL)_isValidDocSetName:(NSString *)fileName
{
    return
		[fileName hasPrefix:@"com.apple"]
		&& [fileName ak_contains:@"iPhone"]
		&& [[fileName pathExtension] isEqualToString:@"docset"];
}

@end
