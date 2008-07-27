/*
 * AKGroupNodeSubtopic.h
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSubtopic.h"

@class AKGroupNode;

@interface AKGroupNodeSubtopic : AKSubtopic
{
    AKGroupNode *_groupNode;
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*!
 * @method      initWithGroupNode:
 * @discussion  Designated initializer.
 */
- (id)initWithGroupNode:(AKGroupNode *)groupNode;

@end
