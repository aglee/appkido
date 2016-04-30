/*
 * AKSortUtils.h
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "AKSortable.h"

/*!
 * Utility methods that sort collections of objects that implement AKSortable
 * either formally or informally.
 */
@interface AKSortUtils : NSObject

/*! Sorts the array elements alphabetically by their -sortName. */
+ (NSArray *)arrayBySortingArray:(NSArray *)anArray;

/*! Sorts the set elements alphabetically by their -sortName. */
+ (NSArray *)arrayBySortingSet:(NSSet *)aSet;

@end
