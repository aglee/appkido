/*
 * AKGroupNode.h
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDatabaseNode.h"

/*!
 * @class       AKGroupNode
 * @abstract    Represents a collection of AKDatabaseNodes.
 * @discussion  An AKGroupNode is a wrapper around a collection of
 *              related AKDatabaseNodes, called its subnodes.  It does not
 *              correspond to a programming construct per se; it is just
 *              a way to have named aggregations of nodes.
 *
 *              An AKGroupNode's -nodeName depends on the type of subnodes
 *              it has and how the group node is used.
 */
@interface AKGroupNode : AKDatabaseNode
{
@private
    // Elements are AKDatabaseNodes.
    NSMutableArray *_subnodes;
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (void)addSubnode:(AKDatabaseNode *)node;

- (int)numberOfSubnodes;

/*!
 * @method      subnodes
 * @discussion  Returns a sorted array.
 */
- (NSArray *)subnodes;

- (AKDatabaseNode *)subnodeWithName:(NSString *)nodeName;

@end
