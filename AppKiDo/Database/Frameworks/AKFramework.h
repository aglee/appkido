//
//  AKFramework.h
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObject.h"

@class AKNamedObjectGroup;
@class AKNamedObjectCluster;

@interface AKFramework : AKNamedObject

@property (strong, readonly) AKNamedObjectGroup *protocolsGroup;
@property (strong, readonly) AKNamedObjectCluster *constantsCluster;
@property (strong, readonly) AKNamedObjectCluster *enumsCluster;
@property (strong, readonly) AKNamedObjectCluster *functionsCluster;
@property (strong, readonly) AKNamedObjectCluster *macrosCluster;
@property (strong, readonly) AKNamedObjectCluster *dataTypesCluster;

@end
