//
//  AKArrayAssortment.h
//  AppKiDo
//
//  Created by Andy Lee on 5/23/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * An AKArrayAssortment is a collection of objects grouped into named arrays.
 */
@interface AKArrayAssortment : NSObject

@property (copy, readonly) NSArray *arrayNames;

- (void)addObject:(id)obj toArrayWithName:(NSString *)name;
- (NSArray *)arrayWithName:(NSString *)name;

//TODO: These could be useful to implement.  I didn't need them for the debugging task I wrote this class for.  Could also be useful to have remove methods and enumerator methods.
//- (NSString *)nameOfArrayContainingObject:(id)obj identical:(BOOL)objectMustBeIdentical;
//- (NSArray *)namesOfArraysContainingObject:(id)obj identical:(BOOL)objectMustBeIdentical;
//- (void)addObjects:(NSArray *)objects keyPathForArrayNames:(NSString *)keyPath nilArrayName:(NSString *)nilArrayName;

@end
