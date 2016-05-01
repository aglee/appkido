//
//  AKRandomSearch.h
//  AppKiDo
//
//  Created by Andy Lee on 3/14/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AKDatabase;
@class AKTokenItem;

/*!
 * Used by the Pop Quiz feature. Selects a random API symbol from the database.
 * You have to first call makeRandomSelection. Then you can ask for the
 * selected API symbol and its corresponding database item. Note that the symbol
 * is not necessarily the item's tokenName -- it could be a "globals" symbol.
 */
@interface AKRandomSearch : NSObject
{
@private
    AKDatabase *_database;
    NSString *_selectedAPISymbol;
}

@property (nonatomic, readonly, copy) NSString *selectedAPISymbol;

#pragma mark - Factory methods

/*! Sends makeRandomSelection to the new instance before returning it. */
+ (instancetype)randomSearchWithDatabase:(AKDatabase *)db;

#pragma mark - Init/awake/dealloc

/*!
 * Designated initializer. You still have to call makeRandomSelection to set
 * selectedAPISymbol and selectedNode. Rather than use this method, it's usually
 * more convenient to use randomSearchWithDatabase:.
 */
- (instancetype)initWithDatabase:(AKDatabase *)db NS_DESIGNATED_INITIALIZER;

#pragma mark - Random selection

- (void)makeRandomSelection;

@end
