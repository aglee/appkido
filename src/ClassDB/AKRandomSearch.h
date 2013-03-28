//
//  AKRandomSearch.h
//  AppKiDo
//
//  Created by Andy Lee on 3/14/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKDatabase;

/*!
 * Used by the Pop Quiz feature. Selects a random API symbol from the database.
 */
@interface AKRandomSearch : NSObject
{
@private
    AKDatabase *_database;
}

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithDatabase:(AKDatabase *)db;

#pragma mark -
#pragma mark Random selection

- (NSString *)randomAPISymbol;

@end
