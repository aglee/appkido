//
//  AKNamedObjectClusterTopic.h
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKTopic.h"

@class AKNamedObjectCluster;

@interface AKNamedObjectClusterTopic : AKTopic

- (instancetype)initWithNamedObjectCluster:(AKNamedObjectCluster *)namedObjectCluster;

@end
