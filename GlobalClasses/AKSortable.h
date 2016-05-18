/*
 * AKSortable.h
 *
 * Created by Andy Lee on Wed Jun 04 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

/*!
 * Informal protocol.  Declares the sortName method used by AKSortUtils.
 */
@protocol AKSortable

@required

@property (readonly, copy) NSString *sortName;

@end
