/*
 * AKGlobalsItem.m
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKGlobalsItem.h"

#import "AKFileSection.h"

@implementation AKGlobalsItem

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenName:(NSString *)tokenName
              database:(AKDatabase *)database
         frameworkName:(NSString *)frameworkName
{
    if ((self = [super initWithTokenName:tokenName database:database frameworkName:frameworkName]))
    {
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
