//
//  AKNamedObjectGroup.h
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObject.h"

//TODO: Consider adding subscripting syntax.
//TODO: Consider "genericizing".  Could enable having a single class, AKNamedObject, which can have subobjects.  Or maybe AKNamedObject plus just AKNamedObjectGroup, which can behave like AKNamedObjectCluster by having its contained objects be themselves groups.  Not important right now: for now, it's simpler to essentially hard-code the hierarchy I happen to be using, and cluster>group>object is clear in my head, and I don't have to do any casting, e.g. objectWithName: returns an AKNamedObject which I would "know" that I can cast to AKNamedObjectGroup.

/*!
 * A named collection of AKNamedObjects.  Object names are unique within the group.
 */
@interface AKNamedObjectGroup : AKNamedObject

@property (assign, readonly) NSInteger count;
@property (copy, readonly) NSArray *sortedObjectNames;
@property (copy, readonly) NSArray *objects;
@property (copy, readonly) NSArray *sortedObjects;

#pragma mark - Accessing objects in the group

- (AKNamedObject *)objectWithName:(NSString *)name;
- (void)addNamedObject:(AKNamedObject *)namedObject;

@end
