//
//  AKCollectionOfItems.m
//  AppKiDo
//
//  Created by Andy Lee on 6/22/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKCollectionOfItems.h"

#import "DIGSLog.h"
#import "AKTokenItem.h"

@implementation AKCollectionOfItems

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)init
{
    if ((self = [super init]))
    {
        _itemList = [[NSMutableArray alloc] init];
        _itemsByName = [[NSMutableDictionary alloc] init];
    }

    return self;
}


#pragma mark -
#pragma mark Getters and setters

- (NSArray *)allItems
{
    return _itemList;
}

- (NSArray *)tokenItemsWithDocumentation
{
    NSMutableArray *result = [NSMutableArray array];

    for (AKTokenItem *tokenItem in _itemList)
    {
        if (tokenItem.tokenItemDocumentation)
        {
            [result addObject:tokenItem];
        }
    }

    return result;
}

- (AKTokenItem *)itemWithTokenName:(NSString *)tokenName
{
    return _itemsByName[tokenName];
}

- (void)addTokenItem:(AKTokenItem *)tokenItem
{
    NSString *tokenName = tokenItem.tokenName;

    if (_itemsByName[tokenName])
    {
        DIGSLogWarning(@"ignoring attempt to add token %@ twice", tokenName);
    }
    else
    {
        [_itemList addObject:tokenItem];
        _itemsByName[tokenName] = tokenItem;
    }
}

@end
