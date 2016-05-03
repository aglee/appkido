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

#pragma mark - Init/awake/dealloc

- (instancetype)init
{
	self = [super init];
	if (self) {
		_itemList = [[NSMutableArray alloc] init];
		_itemsByName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark - Getters and setters

- (NSArray *)allItems
{
	return _itemList;
}

- (AKTokenItem *)itemWithTokenName:(NSString *)tokenName
{
	return _itemsByName[tokenName];
}

- (void)addTokenItem:(AKTokenItem *)tokenItem
{
	NSString *tokenName = tokenItem.tokenName;
	if (_itemsByName[tokenName]) {
		DIGSLogWarning(@"ignoring attempt to add token %@ twice", tokenName);
	} else {
		[_itemList addObject:tokenItem];
		_itemsByName[tokenName] = tokenItem;
	}
}

@end
