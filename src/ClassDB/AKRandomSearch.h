//
//  AKRandomSearch.h
//  AppKiDo
//
//  Created by Andy Lee on 3/14/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKDatabase;
@class AKDocLocator;

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
#pragma mark Searching

- (AKDocLocator *)randomDocLocator;

@end
