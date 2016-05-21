//
//  AKFramework.h
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObject.h"
#import "DocSetModel.h"

@class AKToken;
@class AKTokenCluster;
@class AKNamedObjectGroup;

@interface AKFramework : AKNamedObject

@property (strong, readonly) AKNamedObjectGroup *protocolsGroup;

@property (strong, readonly) AKTokenCluster *constantsCluster;
@property (strong, readonly) AKTokenCluster *enumsCluster;
@property (strong, readonly) AKTokenCluster *functionsCluster;
@property (strong, readonly) AKTokenCluster *macrosCluster;
@property (strong, readonly) AKTokenCluster *typedefsCluster;

- (AKToken *)maybeImportCToken:(DSAToken *)tokenMO;

@end
