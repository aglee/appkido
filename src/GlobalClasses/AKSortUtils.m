/*
 * AKSortUtils.m
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSortUtils.h"

#import "AKClassItem.h"

@implementation AKSortUtils

static
NSComparisonResult
compareSortNames(id objectOne, id objectTwo, void *context)
{
    NSComparisonResult result = [[objectOne sortName] caseInsensitiveCompare:[objectTwo sortName]];

    if (result == NSOrderedSame)
    {
        // Sort class nodes before protocol nodes of the same name.
        if ([objectOne isKindOfClass:[AKClassItem class]])
        {
            result = NSOrderedAscending;
        }
        else
        {
            result = NSOrderedDescending;
        }
    }

    return result;
}

+ (NSArray *)arrayBySortingArray:(NSArray *)anArray
{
    return [anArray sortedArrayUsingFunction:&compareSortNames context:NULL];
}

+ (NSArray *)arrayBySortingSet:(NSSet *)aSet
{
    return [self arrayBySortingArray:aSet.allObjects];
}

@end
