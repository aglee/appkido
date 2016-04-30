/*
 * AKGroupItem.h
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTokenItem.h"

/*!
 * Wrapper around a collection of AKTokenItems, called its subitems. An
 * AKGroupItem does not correspond to any programming language construct; it is
 * just a way to have named aggregations of items.
 */
@interface AKGroupItem : AKTokenItem
{
@private
    // Elements are AKTokenItems.
    NSMutableArray *_subitems;
}

#pragma mark -
#pragma mark Getters and setters

- (void)addSubitem:(AKTokenItem *)item;

@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger numberOfSubitems;

/*! Order of returned nodes is not guaranteed. */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *subitems;

- (AKTokenItem *)subitemWithName:(NSString *)nodeName;

@end
