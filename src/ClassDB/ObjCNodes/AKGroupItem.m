/*
 * AKGroupItem.m
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKGroupItem.h"

#import "AKSortUtils.h"

@implementation AKGroupItem

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithTokenName:(NSString *)tokenName
              database:(AKDatabase *)database
         frameworkName:(NSString *)frameworkName
{
    if ((self = [super initWithTokenName:tokenName database:database frameworkName:frameworkName]))
    {
        _subitems = [[NSMutableArray alloc] init];
    }

    return self;
}


#pragma mark -
#pragma mark Getters and setters

- (void)addSubitem:(AKTokenItem *)item
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

- (AKTokenItem *)subitemWithName:(NSString *)tokenName
{
    for (AKTokenItem *subitem in _subitems)
    {
        if ([subitem.tokenName isEqualToString:tokenName])
        {
            return subitem;
        }
    }

    // If we got this far, the search failed.
    return nil;
}

@end
