//
// AKCategoryToken.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import "AKBehaviorToken.h"

@class AKClassToken;

/*!
 * Represents an Objective-C category.
 */
@interface AKCategoryToken : AKBehaviorToken
@property (weak) AKClassToken *owningClassToken;
@end
