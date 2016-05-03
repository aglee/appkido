//
//  AKCollectionOfItems.h
//  AppKiDo
//
//  Created by Andy Lee on 6/22/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AKTokenItem;

/*!
 * Wrapper around a collection of AKTokenItems, with a couple of convenience
 * methods.  Unlike an AKGroupItem, an AKCollectionOfItems is not itself a item.
 */
@interface AKCollectionOfItems : NSObject
{
@private
	// Contains all the AKTokenItems that have been added to us.
	NSMutableArray *_itemList;

	// Keys are item names.  Values are AKTokenItems.
	NSMutableDictionary *_itemsByName;
}

#pragma mark - Getters and setters

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *allItems;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *tokenItemsWithDocumentation;

- (AKTokenItem *)itemWithTokenName:(NSString *)tokenName;

- (void)addTokenItem:(AKTokenItem *)tokenItem;

@end
