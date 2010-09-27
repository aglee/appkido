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
    if (![fileName hasPrefix:@"com.apple.adc.documentation.Apple"])
    {
        return NO;
    }
    
    if (![[fileName pathExtension] isEqualToString:@"docset"])
    {
        return NO;
    }
    
    if (![fileName ak_contains:@"iPhone"]  &&  ![fileName ak_contains:@"iOS"])
    {
        return NO;
    }
    
    return YES;
}

@end
