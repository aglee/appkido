//
//  AKMacDevTools.m
//  AppKiDo
//
//  Created by Andy Lee on 2/11/09.
//  Copyright 2009 Andy Lee. All rights reserved.
//

#import "AKMacDevTools.h"
#import "NSString+AppKiDo.h"

@implementation AKMacDevTools

#pragma mark -
#pragma mark AKDevTools methods

+ (NSArray *)expectedSubdirsForDevToolsPath:(NSString *)devToolsPath
{
    return @[
             @"Platforms/MacOSX.platform",
             @"Documentation",
             ];
}

- (BOOL)isValidDocSetName:(NSString *)fileName
{
    return ([fileName hasPrefix:@"com.apple.adc.documentation."]
            && [fileName ak_contains:@"OSX"]
            && [fileName hasSuffix:@".docset"]);
}

- (NSString *)sdkSearchPath
{
    return [[self devToolsPath] stringByAppendingPathComponent:@"Platforms/MacOSX.platform/Developer/SDKs/"];
}

@end
