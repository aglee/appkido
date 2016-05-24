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
 * Selects a random name from the frameworks and tokens in a database.
 */
@interface AKRandomSearch : NSObject

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDatabase:(AKDatabase *)db NS_DESIGNATED_INITIALIZER;

#pragma mark - Random selection

- (NSString *)selectRandomName;

@end
