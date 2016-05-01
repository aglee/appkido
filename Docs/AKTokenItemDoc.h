//
//  AKTokenItemDoc.h
//  AppKiDo
//
//  Created by Andy Lee on 8/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKDoc.h"
#import "DocSetModel.h"
#import "AKTokenItem.h"

/*!
 * Documentation associated with a token item.  The relativePath is derived from the
 * token item's DSAToken.
 */
@interface AKTokenItemDoc : AKDoc

@property (nonatomic, strong) AKTokenItem *tokenItem;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenItem:(AKTokenItem *)tokenItem NS_DESIGNATED_INITIALIZER;

@end
