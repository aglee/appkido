/*
 * AKPseudoMethodsSubtopic.m
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKPseudoMethodsSubtopic.h"

#import "DIGSLog.h"

#import "AKClassToken.h"
#import "AKMethodToken.h"
#import "AKMemberDoc.h"

@implementation AKPseudoMethodsSubtopic

#pragma mark - Factory methods

+ (instancetype)subtopicForClassToken:(AKClassToken *)classToken
    includeAncestors:(BOOL)includeAncestors
{
    return [[self alloc] initWithClassToken:classToken
                           includeAncestors:includeAncestors];
}

#pragma mark - Init/awake/dealloc

- (instancetype)initWithClassToken:(AKClassToken *)classToken
       includeAncestors:(BOOL)includeAncestors
{
    if ((self = [super initIncludingAncestors:includeAncestors]))
    {
        _classToken = classToken;
    }

    return self;
}

- (instancetype)initIncludingAncestors:(BOOL)includeAncestors
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithClassToken:nil includeAncestors:NO];
}


#pragma mark - Getters and setters

- (AKClassToken *)classToken
{
    return _classToken;
}

#pragma mark - AKMembersSubtopic methods

- (AKBehaviorToken *)behaviorToken
{
    return _classToken;
}

#pragma mark - Subtopic methods

- (NSString *)stringToDisplayInSubtopicList
{
    return ([self includesAncestors]
            ? [@"       " stringByAppendingString:[self subtopicName]]
            : [self subtopicName]);
}

@end
