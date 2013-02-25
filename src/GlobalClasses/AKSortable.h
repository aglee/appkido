/*
 * AKSortable.h
 *
 * Created by Andy Lee on Wed Jun 04 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

/*!
 * An informal protocol that declares the sort method used by AKSortUtils. The
 * objects you want to sort don't have to formally conform to AKSortable as long
 * as they implement -sortName.
 */
@protocol AKSortable

@required

/*! Returns the sort key to be used by AKSortUtils. */
- (NSString *)sortName;

@end
