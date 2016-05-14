//
// AKToken.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKNamedObject.h"
#import "DocSetModel.h"
#import "AKSortable.h"

@class AKDatabase;
@class DocSetIndex;

/*!
 * Represents a named API construct, as represented by an underlying DSAToken
 * in the docset index (tokenMO).
 */
@interface AKToken : AKNamedObject <AKSortable>

@property (nonatomic, strong) DSAToken *tokenMO;
@property (nonatomic, readonly) NSString *tokenName;
@property (nonatomic, readonly) NSString *frameworkName;
@property (nonatomic, assign) BOOL isDeprecated;

/*!
 * The string to display in the comment field at the bottom of the window.
 * Defaults to the empty string.
 */
@property (copy, readonly) NSString *commentString;

#pragma mark - URLs

- (NSURL *)docURLAccordingToDocSetIndex:(DocSetIndex *)docSetIndex;

@end
