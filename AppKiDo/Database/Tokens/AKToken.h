//
// AKToken.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKNamedObject.h"
#import "DocSetModel.h"

/*!
 * Represents a named API construct, as represented by an underlying DSAToken
 * in the docset index (tokenMO).
 */
@interface AKToken : AKNamedObject

/*! "MO" is for "managed object".  When I see "token" or "tokenMO" in a variable name, I can tell whether it refers to a DSAToken instance (a Core Data managed object) or an AKToken object. */
@property (nonatomic, strong) DSAToken *tokenMO;
@property (nonatomic, copy) NSString *frameworkName;
@property (nonatomic, copy) NSString *fullHeaderPathOutsideOfSDK;
@property (nonatomic, readonly) NSString *headerPathRelativeToSDK;
@property (assign, readonly) BOOL hasHeader;
@property (nonatomic, assign) BOOL isDeprecated;

#pragma mark - Init/awake/dealloc

/*! Note this is not a designated initializer.  It's okay to instantiate an AKToken without a tokenMO, just a name. */
- (instancetype)initWithTokenMO:(DSAToken *)tokenMO;

#pragma mark - Matching URLs

/*! Tries to tell whether the given URL points to documentation about this token. */
- (BOOL)matchesLinkURL:(NSURL *)linkURL;

@end
