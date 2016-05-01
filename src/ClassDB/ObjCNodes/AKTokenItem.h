//
// AKTokenItem.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DocSetModel.h"
#import "AKSortable.h"

@class AKDatabase;
@class AKFileSection;

/*!
 * Base class for entries in an AKDatabase.
 *
 * An AKTokenItem, or just "token item," or just "item," contains information
 * about an API construct. Subclasses represent different types of constructs
 * such as frameworks, classes, and methods.
 *
 * Token items cannot normally change their owning frameworks.  The exception is
 * an AKClassItem, which can belong to multiple frameworks and has a setter for
 * indicating which of them is primary.
 *
 * A token item may have documentation associated with it in the form of an
 * AKFileSection that contains HTML.
 */
@interface AKTokenItem : NSObject <AKSortable>
{
@private
    NSString *_tokenName;
    NSString *_nameOfOwningFramework;
    AKFileSection *_tokenItemDocumentation;
    BOOL _isDeprecated;
}

@property (nonatomic, strong) DSAToken *docSetToken;
@property (nonatomic, readonly, copy) NSString *tokenName;
@property (nonatomic, weak) AKDatabase *owningDatabase;

/*! Most token items belong to exactly one framework. The exception is AKClassItem, because it can have categories that belong to other frameworks. */
@property (nonatomic, copy) NSString *nameOfOwningFramework;

/*! Documentation for the token. Possibly nil. */
@property (nonatomic, strong) AKFileSection *tokenItemDocumentation;

@property (nonatomic, assign) BOOL isDeprecated;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (instancetype)initWithTokenName:(NSString *)tokenName database:(AKDatabase *)database frameworkName:(NSString *)frameworkName NS_DESIGNATED_INITIALIZER;

@end
