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
    return [NSArray arrayWithObjects:
            [[self devToolsPath] stringByAppendingPathComponent:@"Documentation/DocSets/"],
            AKSharedDocSetDirectory,
            AKLibraryDocSetDirectory,
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
