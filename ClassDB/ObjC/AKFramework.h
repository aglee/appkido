//
//  AKFramework.h
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObject.h"

@class AKNamedObjectCluster;

@interface AKFramework : AKNamedObject

@property (strong) AKNamedObjectCluster *constantsCluster;
@property (strong) AKNamedObjectCluster *enumsCluster;
@property (strong) AKNamedObjectCluster *functionsCluster;
@property (strong) AKNamedObjectCluster *macrosCluster;
@property (strong) AKNamedObjectCluster *typedefsCluster;

@end
