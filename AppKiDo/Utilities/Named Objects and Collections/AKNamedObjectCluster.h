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
 * A named collection of AKNamedObjectGroups.  Group names are unique within the
 * object cluster.  This is a way of organizing objects into named "bins", with
 * each object group representing one bin, and with a name (the cluster name)
 * for the collection as a whole.
 */
@interface AKNamedObjectCluster : AKNamedObject

@property (assign, readonly) NSInteger count;
@property (copy, readonly) NSArray *sortedGroupNames;
@property (copy, readonly) NSArray *sortedGroups;

#pragma mark - Accessing groups and objects

- (AKNamedObjectGroup *)groupWithName:(NSString *)objectName;
- (AKNamedObjectGroup *)groupContainingObjectWithName:(NSString *)objectName;
- (void)addNamedObject:(AKNamedObject *)namedObject toGroupWithName:(NSString *)groupName;  //TODO: Handle collisions.

@end
