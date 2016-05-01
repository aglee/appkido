/*
 * AKGroupItemSubtopic.h
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSubtopic.h"

@class AKGroupItem;

/*!
 * Abstract class.
 */
@interface AKGroupItemSubtopic : AKSubtopic
{
@private
    AKGroupItem *_groupItem;
}

@property (nonatomic, readonly, strong) AKGroupItem *groupItem;

#pragma mark - Init/awake/dealloc

/*! Designated initializer. */
- (instancetype)initWithGroupItem:(AKGroupItem *)groupItem NS_DESIGNATED_INITIALIZER;

@end
