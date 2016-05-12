//
//  AKNamedGroup.h
//  AppKiDo
//
//  Created by Andy Lee on 5/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedItem.h"

@interface AKNamedGroup : AKNamedItem

@property (copy, readonly) NSArray *itemNames;
@property (copy, readonly) NSArray *sortedItemNames;

#pragma mark - Managing the items in the group

- (BOOL)hasItemWithName:(NSString *)name;
- (AKNamedItem *)itemWithName:(NSString *)name;

/*! If no item with the same name already exists, adds the given item and returns nil.  Otherwise, returns the pre-existing item and makes no internal change. */
- (AKNamedItem *)addItemIfAbsent:(AKNamedItem *)item;

@end
