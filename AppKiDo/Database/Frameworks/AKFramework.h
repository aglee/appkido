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

// Note that while these named object collections are readonly, they are mutable.
@property (strong, readonly) AKNamedObjectGroup *protocolsGroup;
@property (strong, readonly) AKNamedObjectGroup *classesGroup;
@property (strong, readonly) AKNamedObjectCluster *functionsAndGlobalsCluster;

@end
