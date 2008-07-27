/*
 * AKSortable.h
 *
 * Created by Andy Lee on Wed Jun 04 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

/*!
 * @protocol    AKSortable
 * @discussion  An informal protocol that declares the sort method used
 *              by AKSortUtils.  The objects you want to sort don't have
 *              to formally implement AKSortable as long as they
 *              implement -sortName.
 */
@protocol AKSortable

/*!
 * @method      sortName
 * @discussion  Returns the value on which I should be sorted by the
 *              sorting methods in AKSortUtils.
 */
- (NSString *)sortName;

@end
