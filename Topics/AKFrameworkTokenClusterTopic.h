/*
 * AKFrameworkTokenClusterTopic.h
 *
 * Created by Andy Lee on Sat May 14 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKNamedObjectClusterTopic.h"

@class AKFramework;
@class AKNamedObjectCluster;

/*!
 * Used for some child topics of an AKFrameworkTopic.
 */
@interface AKFrameworkTokenClusterTopic : AKNamedObjectClusterTopic

@property (copy, readonly) AKFramework *framework;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithNamedObjectCluster:(AKNamedObjectCluster *)namedObjectCluster
                                 framework:(AKFramework *)framework NS_DESIGNATED_INITIALIZER;

@end
