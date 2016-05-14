/*
 * AKGroupItem.h
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKToken.h"

/*!
 * Wrapper around a collection of AKTokens, called its subitems. An
 * AKGroupItem does not correspond to any programming language construct; it is
 * just a way to have named aggregations of items.
 */
@interface AKGroupItem : AKToken
{
@private
    // Elements are AKTokens.
    NSMutableArray *_subitems;
}

@property (copy) NSString *groupName;
@property (copy) NSString *fallbackFrameworkName;

#pragma mark - Getters and setters

- (void)addSubitem:(AKToken *)item;

@property (readonly) NSInteger numberOfSubitems;

/*! Order of returned items is not guaranteed. */
@property (readonly, copy) NSArray *subitems;

- (AKToken *)subitemWithName:(NSString *)tokenName;

@end
