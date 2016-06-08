//
//  AKNamedObjectGroup.h
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObject.h"

//TODO: Why did I have the objects in the group inherit from AKNamedObject instead of conforming to <AKNamed>, which would be more flexible?  Maybe it was just a matter of getting around to it?

//TODO: For AppKiDo I haven't (so far) needed any kind of remove methods, but that could change.

//TODO: Consider "genericizing" so that groups/clusters expect their objects to be of a specific class or protocol.  Benefits?


/*!
 * A named collection of AKNamedObjects.  Object names are unique within the
 * object group.
 *
 * Functionally this is similar to a dictionary of named objects where the
 * dictionary keys are always the object names, with the addition of a name (the
 * group name) for the dictionary as a whole.
 */
@interface AKNamedObjectGroup : AKNamedObject

@property (assign, readonly) NSInteger count;
@property (copy, readonly) NSArray *sortedObjectNames;
@property (copy, readonly) NSArray *objects;
@property (copy, readonly) NSArray *sortedObjects;

#pragma mark - Accessing objects in the group

- (AKNamedObject *)objectWithName:(NSString *)name;
/*! If there is a name collision, the new object replaces the existing one. */
- (void)addNamedObject:(AKNamedObject *)namedObject;  //TODO: Consider returning the old object where there is a collision.

@end
