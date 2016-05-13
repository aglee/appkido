//
//  AKTokenDoc.h
//  AppKiDo
//
//  Created by Andy Lee on 8/24/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKDoc.h"
#import "DocSetModel.h"
#import "AKToken.h"

/*!
 * Documentation associated with a token item.  The relativePath is derived from the
 * token item's DSAToken.
 */
@interface AKTokenDoc : AKDoc

@property (nonatomic, strong) AKToken *token;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithToken:(AKToken *)token NS_DESIGNATED_INITIALIZER;

@end
