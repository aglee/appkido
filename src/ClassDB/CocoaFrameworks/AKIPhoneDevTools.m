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
    // Are we using the standalone Xcode introduced by Xcode 4.3
    // or the older package-installation model?
    if ([AKDevTools devToolsPathIsOldStyle:devToolsPath])
    {
        return (@[
                @"Platforms/iPhoneOS.platform",
                @"Platforms/iPhoneSimulator.platform",
                @"Applications/Xcode.app",
                @"Documentation",
                @"Examples",
                ]);
    }
    else
    {
        return (@[
                @"Platforms/iPhoneOS.platform",
                @"Platforms/iPhoneSimulator.platform",
                @"Documentation",
                ]);
    }
}

- (NSArray *)docSetSearchPaths
{
    // NOTE: Order matters. On 2011-10-31, Gerriet reported that NSFileVersion (new in 10.7) wasn't
    // appearing in AppKiDo even though it did appear in the Xcode doc window. I reproduced the bug
    // and noticed that I had *two* Lion docsets: one in AKLibraryDocSetDirectory which did not
    // contain NSFileVersion, and a newer one in AKSharedDocSetDirectory which did. So I moved
    // AKSharedDocSetDirectory later in this array so that it "wins" when docsets appear in both
    // places. This fixed the problem, at least for me.
    return (@[
            [[self devToolsPath] stringByAppendingPathComponent:@"Platforms/iPhoneOS.platform/Developer/Documentation/DocSets/"],
            AKLibraryDocSetDirectory,
            AKSharedDocSetDirectory,

            // New directories to look in as of Xcode 4.3.
            [NSHomeDirectory() stringByAppendingPathComponent:AKSharedDocSetDirectory],
            ]);
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
