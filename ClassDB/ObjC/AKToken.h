//
// AKToken.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKNamedObject.h"
#import "AKDocListItem.h"
#import "DocSetModel.h"

/*!
 * Represents a named API construct, as represented by an underlying DSAToken
 * in the docset index (tokenMO).
 *
 * In practice, not all AKTokens are potentially doc list items, but most are,
 * so it's simpler to declare AKToken to conform to AKDocListItem.  The way it's
 * implemented should work for all tokens if they *were* to be doc list items.
 */
@interface AKToken : AKNamedObject <AKDocListItem>

/*! "MO" is for "managed object", to help me tell whether I'm referring to a DSAToken instance or an AKToken object. */
@property (nonatomic, strong) DSAToken *tokenMO;
@property (nonatomic, copy) NSString *frameworkName;
@property (nonatomic, readonly) NSString *headerPath;
@property (nonatomic, assign) BOOL isDeprecated;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithTokenMO:(DSAToken *)tokenMO;

@end
