//
//  AKArrayAssortment.h
//  AppKiDo
//
//  Created by Andy Lee on 5/23/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * Dashed this off to help debugging.  Decided to keep it in case useful later.
 *
 * Doesn't check for collisions within arrays.  Is just a way to "bin" things by name.
 */
@interface AKArrayAssortment : NSObject

@property (copy, readonly) NSArray *arrayNames;

- (void)addObject:(id)obj toArrayWithName:(NSString *)name;
- (NSArray *)arrayWithName:(NSString *)name;

@end
