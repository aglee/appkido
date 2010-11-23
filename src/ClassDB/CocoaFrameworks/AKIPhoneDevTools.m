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

- (NSArray *)docSetSearchPaths
{
    return [NSArray arrayWithObjects:
            [[self devToolsPath] stringByAppendingPathComponent:@"Platforms/iPhoneOS.platform/Developer/Documentation/DocSets/"],
            AKSharedDocSetDirectory,
            nil];
}

- (BOOL)isValidDocSetName:(NSString *)fileName
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

- (NSString *)sdkSearchPath
{
    return [[self devToolsPath] stringByAppendingPathComponent:@"Platforms/iPhoneOS.platform/Developer/SDKs/"];
}

@end
