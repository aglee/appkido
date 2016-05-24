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
 * Selects a random token name from the specified database.
 */
@interface AKRandomSearch : NSObject

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDatabase:(AKDatabase *)db NS_DESIGNATED_INITIALIZER;

#pragma mark - Random selection

- (NSString *)selectRandomTokenName;

@end
