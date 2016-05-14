//
// AKMethodToken.m
//
// Created by Andy Lee on Thu Jun 27 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKMethodToken.h"

@implementation AKMethodToken

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name
{
    NSAssert(self.class != AKMethodToken.class, @"Attempt to instantiate abstract class %@", self.className);
    return [super initWithName:name];
}

@end
