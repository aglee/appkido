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

- (void)setFWDatabase:(AKDatabase *)theDatabase
{
    _fwDatabase = theDatabase;
}

- (NSString *)frameworkName
{
    return _frameworkName;
}

- (void)setFrameworkName:(NSString *)name
{
    [name retain];
    [_frameworkName release];
    _frameworkName = name;
}

@end
