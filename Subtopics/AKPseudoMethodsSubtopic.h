/*
 * AKPseudoMethodsSubtopic.h
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKMembersSubtopic.h"

@class AKClassToken;

@interface AKPseudoMethodsSubtopic : AKMembersSubtopic
{
@private
    AKClassToken *_classToken;
}

#pragma mark - Factory methods

+ (instancetype)subtopicForClassToken:(AKClassToken *)classToken
          includeAncestors:(BOOL)includeAncestors;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithClassToken:(AKClassToken *)classToken
       includeAncestors:(BOOL)includeAncestors NS_DESIGNATED_INITIALIZER;

#pragma mark - Getters and setters

@property (NS_NONATOMIC_IOSONLY, readonly, strong) AKClassToken *classToken;

@end
