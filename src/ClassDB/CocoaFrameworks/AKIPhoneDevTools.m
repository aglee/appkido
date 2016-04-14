//
//  AKIPhoneDevTools.m
//  AppKiDo
//
//  Created by Andy Lee on 2/11/09.
//  Copyright 2009 Andy Lee. All rights reserved.
//

#import "AKIPhoneDevTools.h"
#import "NSString+AppKiDo.h"

@implementation AKIPhoneDevTools

#pragma mark -
#pragma mark AKDevTools methods

+ (NSArray *)expectedSubdirsForDevToolsPath:(NSString *)devToolsPath
{
    return @[
             @"Platforms/iPhoneOS.platform",
             @"Platforms/iPhoneSimulator.platform",
             @"Documentation",
             ];
}

- (BOOL)isValidDocSetName:(NSString *)fileName
{
    return ([fileName hasPrefix:@"com.apple.adc.documentation."]
            && [fileName ak_contains:@"iOS"]
            && [fileName hasSuffix:@".docset"]);
}

- (NSString *)sdkSearchPath
{
    return [[self devToolsPath] stringByAppendingPathComponent:@"Platforms/iPhoneOS.platform/Developer/SDKs/"];
}

@end
