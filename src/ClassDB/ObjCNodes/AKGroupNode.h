/*
 * AKGroupNode.h
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDatabaseNode.h"

/*!
 * Wrapper around a collection of AKDatabaseNodes, called its subnodes. An
 * AKGroupNode does not correspond to any programming language construct; it is
 * just a way to have named aggregations of nodes.
 */
@interface AKGroupNode : AKDatabaseNode
{
@private
    // Elements are AKDatabaseNodes.
    NSMutableArray *_subnodes;
}

#pragma mark -
#pragma mark Getters and setters

- (void)addSubnode:(AKDatabaseNode *)node;

@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger numberOfSubnodes;

/*! Order of returned nodes is not guaranteed. */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *subnodes;

- (AKDatabaseNode *)subnodeWithName:(NSString *)nodeName;

@end
