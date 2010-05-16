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

- (NSString *)_relativePathToDocSetsDir
{
    return @"Documentation/DocSets/";
}

- (NSString *)_relativePathToSDKsDir
{
    return @"SDKs/";
}

- (BOOL)_isValidDocSetName:(NSString *)fileName
{
    return
		[fileName hasPrefix:@"com.apple"]
		&& [fileName hasSuffix:@"CoreReference.docset"];
}

@end
