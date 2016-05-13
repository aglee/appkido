//
// AKToken.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DocSetModel.h"
#import "AKSortable.h"

@class AKDatabase;

/*!
 * Represents a named API construct.  Subclasses represent different types of
 * constructs such as classes, protocols, and methods.
 */
@interface AKToken : NSObject <AKSortable>

@property (nonatomic, strong) DSAToken *tokenMO;
@property (nonatomic, readonly) NSString *tokenName;
@property (nonatomic, readonly) NSString *frameworkName;
@property (nonatomic, assign) BOOL isDeprecated;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithToken:(DSAToken *)token NS_DESIGNATED_INITIALIZER;

@end