//
//  AKMacDevTools.m
//  AppKiDo
//
//  Created by Andy Lee on 2/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AKMacDevTools.h"

@implementation AKMacDevTools

#pragma mark -
#pragma mark AKDevTools methods

- (NSArray *)docSetSearchPaths
{
    // NOTE: Order matters. On 2011-10-31, Gerriet reported that NSFileVersion (new in 10.7) wasn't
    // appearing in AppKiDo even though it did appear in the Xcode doc window. I reproduced the bug
    // and noticed that I had *two* Lion docsets: one in AKLibraryDocSetDirectory which did not
    // contain NSFileVersion, and a newer one in AKSharedDocSetDirectory which did. So I moved
    // AKSharedDocSetDirectory to the end of this array so that it "wins" when docsets appear in both
    // places. This fixed the problem, at least for me.
    return [NSArray arrayWithObjects:
            [[self devToolsPath] stringByAppendingPathComponent:@"Documentation/DocSets/"],
            AKLibraryDocSetDirectory,
            AKSharedDocSetDirectory,
            nil];
}

- (BOOL)isValidDocSetName:(NSString *)fileName
{
    return ([fileName hasPrefix:@"com.apple"]
            && [fileName hasSuffix:@"CoreReference.docset"]);
}

- (NSString *)sdkSearchPath
{
    return [[self devToolsPath] stringByAppendingPathComponent:@"SDKs/"];
}

@end
