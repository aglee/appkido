/*
 * AKPseudoMethodsSubtopic.h
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKMembersSubtopic.h"

@class AKClassNode;

@interface AKPseudoMethodsSubtopic : AKMembersSubtopic
{
@private
    AKClassNode *_classNode;
}

#pragma mark -
#pragma mark Factory methods

+ (instancetype)subtopicForClassNode:(AKClassNode *)classNode
          includeAncestors:(BOOL)includeAncestors;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (instancetype)initWithClassNode:(AKClassNode *)classNode
       includeAncestors:(BOOL)includeAncestors NS_DESIGNATED_INITIALIZER;

#pragma mark -
#pragma mark Getters and setters

@property (NS_NONATOMIC_IOSONLY, readonly, strong) AKClassNode *classNode;

@end
