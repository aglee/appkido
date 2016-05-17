//
//  AKNamedObjectGroup.h
//  AppKiDo
//
//  Created by Andy Lee on 5/16/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObject.h"

/*!
 * A named collection of AKNamedObjects.
 */
@interface AKNamedObjectGroup : AKNamedObject

@property (copy, readonly) NSArray *sortedObjectNames;
@property (copy, readonly) NSArray *sortedObjects;

#pragma mark - Accessing objects in the group

- (AKNamedObject *)objectWithName:(NSString *)name;
- (void)addNamedObject:(AKNamedObject *)namedObject;

@end
