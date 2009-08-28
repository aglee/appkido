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

- (NSString *)relativePathToDocSetsDir
{
    return @"Documentation/DocSets/";
}

- (NSString *)relativePathToHeadersDir
{
    return @"SDKs/";
}

- (BOOL)isValidDocSetName:(NSString *)fileName
{
    return [fileName hasSuffix:@"CoreReference.docset"];
}

@end