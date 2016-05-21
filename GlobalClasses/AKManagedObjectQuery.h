//
//  AKManagedObjectQuery.h
//  AppKiDo
//
//  Created by Andy Lee on 4/29/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AKResult;

/*!
 * Convenience methods for doing simple Core Data fetches.
 */
@interface AKManagedObjectQuery : NSObject

@property (copy) NSArray *keyPaths;
/*! No placeholders, just a string. */
@property (copy) NSString *predicateString;
/*! Defaults to YES, just like NSFetchRequest. */
@property (assign) BOOL returnsObjectsAsFaults;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithMOC:(NSManagedObjectContext *)moc entityName:(NSString *)entityName NS_DESIGNATED_INITIALIZER;

#pragma mark - Executing fetch requests

- (AKResult *)fetchObjects;

/*! Uses self.keyPaths for propertiesToFetch, and uses NSDictionaryResultType for the fetch request. */
- (AKResult *)fetchDistinctObjects;

@end
