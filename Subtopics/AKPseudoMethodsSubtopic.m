/*
 * AKPseudoMethodsSubtopic.m
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKPseudoMethodsSubtopic.h"

#import "DIGSLog.h"

#import "AKClassItem.h"
#import "AKMethodItem.h"
#import "AKMemberDoc.h"

@implementation AKPseudoMethodsSubtopic

#pragma mark - Factory methods

+ (instancetype)subtopicForClassItem:(AKClassItem *)classItem
    includeAncestors:(BOOL)includeAncestors
{
    return [[self alloc] initWithClassItem:classItem
                           includeAncestors:includeAncestors];
}

#pragma mark - Init/awake/dealloc

- (instancetype)initWithClassItem:(AKClassItem *)classItem
       includeAncestors:(BOOL)includeAncestors
{
    if ((self = [super initIncludingAncestors:includeAncestors]))
    {
        _classItem = classItem;
    }

    return self;
}

- (instancetype)initIncludingAncestors:(BOOL)includeAncestors
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithClassItem:nil includeAncestors:NO];
}


#pragma mark - Getters and setters

- (AKClassItem *)classItem
{
    return _classItem;
}

#pragma mark - AKMembersSubtopic methods

- (AKBehaviorItem *)behaviorItem
{
    return _classItem;
}

@end
