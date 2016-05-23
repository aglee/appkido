/*
 * AKFrameworkTokenClusterTopic.h
 *
 * Created by Andy Lee on Sat May 14 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKFrameworkRelatedTopic.h"

@class AKNamedObjectCluster;

/*!
 * No child topics.  One subtopic for each group in the token cluster.
 */
@interface AKFrameworkTokenClusterTopic : AKFrameworkRelatedTopic

#pragma mark - Init/awake/dealloc

- (instancetype)initWithFramework:(AKFramework *)framework
                     tokenCluster:(AKNamedObjectCluster *)tokenCluster NS_DESIGNATED_INITIALIZER;

@end
