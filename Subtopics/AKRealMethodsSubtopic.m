/*
 * AKRealMethodsSubtopic.m
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKRealMethodsSubtopic.h"

#import "DIGSLog.h"

#import "AKClassItem.h"
#import "AKMethodItem.h"
#import "AKMemberDoc.h"

@implementation AKRealMethodsSubtopic

#pragma mark - Factory methods

+ (instancetype)subtopicForBehaviorItem:(AKBehaviorItem *)behaviorItem
             includeAncestors:(BOOL)includeAncestors
{
    return [[self alloc] initWithBehaviorItem:behaviorItem
                              includeAncestors:includeAncestors];
}

#pragma mark - Init/awake/dealloc

- (instancetype)initWithBehaviorItem:(AKBehaviorItem *)behaviorItem
          includeAncestors:(BOOL)includeAncestors
{
    if ((self = [super initIncludingAncestors:includeAncestors]))
    {
        _behaviorItem = behaviorItem;
    }

    return self;
}

- (instancetype)initIncludingAncestors:(BOOL)includeAncestors
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithBehaviorItem:nil includeAncestors:NO];
}


#pragma mark - AKMembersSubtopic methods

- (AKBehaviorItem *)behaviorItem
{
    return _behaviorItem;
}

@end
