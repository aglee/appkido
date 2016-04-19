/*
 * AKGroupNodeSubtopic.h
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSubtopic.h"

@class AKGroupNode;

/*!
 * Abstract class.
 */
@interface AKGroupNodeSubtopic : AKSubtopic
{
@private
    AKGroupNode *_groupNode;
}

@property (nonatomic, readonly, strong) AKGroupNode *groupNode;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithGroupNode:(AKGroupNode *)groupNode;

@end
