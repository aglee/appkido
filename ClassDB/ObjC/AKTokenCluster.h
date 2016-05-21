//
//  AKTokenCluster.h
//  AppKiDo
//
//  Created by Andy Lee on 5/19/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObjectCluster.h"

@class AKToken;
@class DSAToken;

@interface AKTokenCluster : AKNamedObjectCluster

/*! Returns a new AKToken object, after adding it to self. */
- (AKToken *)tokenWithTokenMO:(DSAToken *)tokenMO;

@end
