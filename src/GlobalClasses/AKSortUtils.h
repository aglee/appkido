/*
 * AKSortUtils.h
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import "AKSortable.h"

/*!
 * @class       AKSortUtils
 * @discussion  Utility methods that sort collections of objects that
 *              implement AKSortable either formally or informally.
 */
@interface AKSortUtils : NSObject
{
}

/*!
 * @method      arrayBySortingArray:
 * @discussion  Sorts the elements of the given array alphabetically by
 *              the value they return for -sortName.
 */
+ (NSArray *)arrayBySortingArray:(NSArray *)nodeArray;

/*!
 * @method      arrayBySortingSet:
 * @discussion  Sorts the elements of the given set alphabetically by
 *              the value they return for -sortName.
 */
+ (NSArray *)arrayBySortingSet:(NSSet *)nodeSet;

@end
