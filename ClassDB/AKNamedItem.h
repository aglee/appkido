//
//  AKNamedItem.h
//  AppKiDo
//
//  Created by Andy Lee on 5/12/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKNamedItem : NSObject

@property (copy) NSString *name;
@property (copy, readonly) NSString *sortName;
@property (copy, readonly) NSString *displayName;
/*! Returns nil for leaf nodes. */
@property (copy, readonly) NSArray *subitems;
@property (copy, readonly) NSArray *sortedSubitems;
@property (weak, readonly) AKNamedItem *superitem;

#pragma mark - Managing subitems

- (BOOL)hasSubitemWithName:(NSString *)name;
- (AKNamedItem *)subitemWithName:(NSString *)name;

/*! If no item with the same name already exists, adds the given item and returns nil.  Otherwise, returns the pre-existing item and makes no internal change. */
- (AKNamedItem *)addSubitemIfAbsent:(AKNamedItem *)subitem;

@end
