//
//  NSArray+AppKiDo.h
//  AppKiDo
//
//  Created by Andy Lee on 5/24/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKSortable.h"

@interface NSArray (AppKiDo)

- (NSArray *)ak_sortedStrings;
- (NSArray *)ak_sortedBySortName;
- (NSString *)ak_joinedBySpaces;
- (NSArray *)ak_arrayByRemovingLast:(NSInteger)numObjectsToRemove;

@end
