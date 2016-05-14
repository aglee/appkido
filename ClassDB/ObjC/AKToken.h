//
// AKToken.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKNamedCollection.h"
#import "DocSetModel.h"
#import "AKSortable.h"

@class AKDatabase;

/*!
 * Represents a named API construct, as represented by an underlying DSAToken
 * in the docset index (tokenMO).
 */
@interface AKToken : AKNamedObject <AKSortable>

@property (nonatomic, strong) DSAToken *tokenMO;
@property (nonatomic, readonly) NSString *tokenName;
@property (nonatomic, readonly) NSString *frameworkName;
@property (nonatomic, assign) BOOL isDeprecated;

@end
