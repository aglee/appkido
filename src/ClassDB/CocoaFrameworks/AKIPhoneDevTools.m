//
//  AKIPhoneDevTools.m
//  AppKiDo
//
//  Created by Andy Lee on 2/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AKIPhoneDevTools.h"


@implementation AKIPhoneDevTools

#pragma mark -
#pragma mark AKDevTools methods

- (NSString *)relativePathToDocSetsDir
{
    return @"Platforms/iPhoneOS.platform/Developer/Documentation/DocSets/";
}

- (NSString *)relativePathToHeadersDir
{
    return @"Platforms/iPhoneOS.platform/Developer/SDKs/";
}

- (BOOL)isValidDocSetName:(NSString *)fileName
{
    return [[fileName pathExtension] isEqualToString:@"docset"];
}

@end
