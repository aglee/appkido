/*
 * AKPseudoMethodsSubtopic.h
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKMembersSubtopic.h"

@class AKClassItem;

@interface AKPseudoMethodsSubtopic : AKMembersSubtopic
{
@private
    AKClassItem *_classItem;
}

#pragma mark - Factory methods

+ (instancetype)subtopicForClassItem:(AKClassItem *)classItem
          includeAncestors:(BOOL)includeAncestors;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithClassItem:(AKClassItem *)classItem
       includeAncestors:(BOOL)includeAncestors NS_DESIGNATED_INITIALIZER;

#pragma mark - Getters and setters

@property (NS_NONATOMIC_IOSONLY, readonly, strong) AKClassItem *classItem;

@end
