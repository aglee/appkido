//
//  AKDocSetQuery.h
//  AppKiDo
//
//  Created by Andy Lee on 4/29/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocSetModel.h"

@class DocSetIndex;

/*!
    TODO: Document the convenience syntax ("%ident%" etc.).
 */
@interface AKDocSetQuery : NSObject

@property (strong, readonly) DocSetIndex *docSetIndex;
@property (copy, readonly) NSString *entityName;
/*! If non-empty, the specified key paths are used for propertiesToFetch, and the fetch request is NSDictionaryResultType. */
@property (copy) NSString *distinctKeyPathsString;
@property (copy) NSString *predicateString;

#pragma mark - Factory methods

+ (instancetype)queryWithDocSetIndex:(DocSetIndex *)docSetIndex entityName:(NSString *)entityName;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDocSetIndex:(DocSetIndex *)docSetIndex entityName:(NSString *)entityName NS_DESIGNATED_INITIALIZER;

#pragma mark - Querying the DocSetIndex

- (NSArray *)fetchObjectsWithError:(NSError **)errorPtr;

@end
