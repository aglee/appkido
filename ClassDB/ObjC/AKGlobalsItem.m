/*
 * AKGlobalsItem.m
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKGlobalsItem.h"

@implementation AKGlobalsItem

#pragma mark - Init/awake/dealloc

- (instancetype)initWithName:(NSString *)name
{
    self = [super initWithName:name];
    if (self) {
        _namesOfGlobals = [[NSMutableArray alloc] init];
    }

    return self;
}

#pragma mark - Getters and setters

- (void)addNameOfGlobal:(NSString *)nameOfGlobal
{
    [_namesOfGlobals addObject:nameOfGlobal];
}

- (NSArray *)namesOfGlobals
{
    return _namesOfGlobals;
}

@end
