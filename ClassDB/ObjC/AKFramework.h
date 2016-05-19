//
//  AKFramework.h
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObject.h"

@class AKTokenCluster;
@class AKNamedObjectGroup;

@interface AKFramework : AKNamedObject

@property (strong) AKNamedObjectGroup *protocolsGroup;

@property (strong) AKTokenCluster *constantsCluster;
@property (strong) AKTokenCluster *enumsCluster;
@property (strong) AKTokenCluster *functionsCluster;
@property (strong) AKTokenCluster *macrosCluster;
@property (strong) AKTokenCluster *typedefsCluster;

@end
