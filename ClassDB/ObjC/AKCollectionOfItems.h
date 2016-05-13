//
//  AKCollectionOfItems.h
//  AppKiDo
//
//  Created by Andy Lee on 6/22/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AKToken;

/*!
 * Wrapper around a collection of AKTokens, with a couple of convenience
 * methods.  Unlike an AKGroupItem, an AKCollectionOfItems is not itself a item.
 */
@interface AKCollectionOfItems : NSObject
{
@private
	// Contains all the AKTokens that have been added to us.
	NSMutableArray *_itemList;

	// Keys are item names.  Values are AKTokens.
	NSMutableDictionary *_itemsByName;
}

#pragma mark - Getters and setters

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *allItems;

- (AKToken *)itemWithTokenName:(NSString *)tokenName;

- (void)addToken:(AKToken *)token;

@end
