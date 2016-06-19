//
//  AKSortUtils.h
//  AppKiDo
//
//  Created by Andy Lee on 6/19/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * Assumes it is strings that are being sorted, and that the desired order is
 * ascending.  Uses localizedStandardCompare: for the sort.
 */
extern NSSortDescriptor *AKFinderLikeSort(NSString *keyPath);

