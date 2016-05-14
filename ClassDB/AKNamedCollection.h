//
//  AKNamedCollection.h
//  AppKiDo
//
//  Created by Andy Lee on 5/13/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKNamedObject.h"

@interface AKNamedCollection : AKNamedObject

@property (copy, readonly) NSArray *elementNames;
@property (copy, readonly) NSArray *sortedElementNames;
@property (copy, readonly) NSArray *elements;
@property (copy, readonly) NSArray *sortedElements;

#pragma mark - Managing elements

- (BOOL)hasElementWithName:(NSString *)name;
- (AKNamedObject *)elementWithName:(NSString *)name;

/*! If no element with the same name already exists, adds the given element and returns nil.  Otherwise, returns the pre-existing element and makes no internal change. */
- (AKNamedObject *)addElementIfAbsent:(AKNamedObject *)element;

@end
