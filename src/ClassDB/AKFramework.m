//
//  AKFramework.m
//  AppKiDo
//
//  Created by Andy Lee on 6/15/09.
//  Copyright 2009 Andy Lee. All rights reserved.
//

#import "AKFramework.h"


@implementation AKFramework

#pragma mark -
#pragma mark NSObject methods

- (NSString *)description
{
    return _frameworkName;
}


- (BOOL)isEqual:(id)anObject
{
    if (![anObject isMemberOfClass:[AKFramework class]])
    {
        return NO;
    }
    return [_frameworkName isEqualToString:[anObject frameworkName]];
}

- (NSUInteger)hash
{
    return [_frameworkName hash];
}

@end
