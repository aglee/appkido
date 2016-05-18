//
//  AKNamedObjectCluster.h
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObject.h"

@class AKNamedObjectGroup;

/*!
 * A named collection of AKNamedObjectGroups.  Object names are unique within the cluster.
 */
@interface AKNamedObjectCluster : AKNamedObject

@property (copy, readonly) NSArray *sortedGroupNames;
@property (copy, readonly) NSArray *sortedGroups;

#pragma mark - Accessing token groups

- (AKNamedObjectGroup *)groupContainingObjectWithName:(NSString *)objectName;
- (void)addNamedObject:(AKNamedObject *)namedObject toGroupWithName:(NSString *)groupName;  //TODO: Handle collisions.

@end
