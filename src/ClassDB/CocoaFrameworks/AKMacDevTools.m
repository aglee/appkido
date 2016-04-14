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
    // Are we using the standalone Xcode introduced by Xcode 4.3
    // or the older package-installation model?
    if ([AKDevTools devToolsPathIsOldStyle:devToolsPath])
    {
        return (@[
                @"Applications/Xcode.app",
                @"Documentation",
                @"Examples",
                ]);
    }
    else
    {
        return (@[
                @"Platforms/MacOSX.platform",
                @"Documentation",
                ]);
    }
}

- (BOOL)isValidDocSetName:(NSString *)fileName
{
    return ([fileName hasPrefix:@"com.apple.adc.documentation."]
            && [fileName ak_contains:@"OSX"]
            && [fileName hasSuffix:@".docset"]);
}

- (NSString *)sdkSearchPath
{
    // Are we using the standalone Xcode introduced by Xcode 4.3
    // or the older Dev Tools installation model?
    if ([AKDevTools devToolsPathIsOldStyle:[self devToolsPath]])
    {
        return [[self devToolsPath] stringByAppendingPathComponent:@"SDKs/"];
    }
    else
    {
        return [[self devToolsPath] stringByAppendingPathComponent:@"Platforms/MacOSX.platform/Developer/SDKs/"];
    }
}

@end
