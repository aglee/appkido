//
//  AKFramework.m
//  AppKiDo
//
//  Created by Andy Lee on 6/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AKFramework.h"


@implementation AKFramework

- (AKDatabase *)fwDatabase
{
    return _fwDatabase;
}

- (void)setFWDatabase:(AKDatabase *)aDatabase
{
    _fwDatabase = aDatabase;
}

- (NSString *)frameworkName
{
    return _frameworkName;
}

- (void)setFrameworkName:(NSString *)frameworkName
{
    [frameworkName retain];
    [_frameworkName release];
    _frameworkName = frameworkName;
}

@end
