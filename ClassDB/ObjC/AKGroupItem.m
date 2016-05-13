/*
 * AKGroupItem.m
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKGroupItem.h"
#import "AKSortUtils.h"

@implementation AKGroupItem

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenMO:(DSAToken *)tokenMO
{
    self = [super initWithTokenMO:tokenMO];
    if (self) {
        _subitems = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Getters and setters

- (void)addSubitem:(AKToken *)item
{
    [_subitems addObject:item];
}

- (NSInteger)numberOfSubitems
{
    return _subitems.count;
}

- (NSArray *)subitems
{
    return _subitems;
}

- (AKToken *)subitemWithName:(NSString *)tokenName
{
    for (AKToken *subitem in _subitems)
    {
        if ([subitem.tokenName isEqualToString:tokenName])
        {
            return subitem;
        }
    }
    return nil;
}

#pragma mark - AKToken methods

- (NSString *)tokenName
{
    return self.groupName;
}

- (NSString *)frameworkName
{
    return self.fallbackFrameworkName;
}

@end
