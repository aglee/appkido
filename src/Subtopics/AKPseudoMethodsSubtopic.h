/*
 * AKPseudoMethodsSubtopic.h
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKMethodsSubtopic.h"

@class AKClassNode;

@interface AKPseudoMethodsSubtopic : AKMethodsSubtopic
{
@private
    AKClassNode *_classNode;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

// convenience method uses the designated initializer
+ (id)subtopicForClassNode:(AKClassNode *)classNode
    includeAncestors:(BOOL)includeAncestors;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

// Designated initializer
- (id)initWithClassNode:(AKClassNode *)classNode
    includeAncestors:(BOOL)includeAncestors;

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (AKClassNode *)classNode;

@end

