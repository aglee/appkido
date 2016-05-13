//
//  AKBindingsSubtopic.m
//  AppKiDo
//
//  Created by Andy Lee on 5/1/16.
//  Copyright © 2016 Andy Lee. All rights reserved.
//

#import "AKBindingsSubtopic.h"
#import "AKClassToken.h"
#import "AKBindingDoc.h"

@implementation AKBindingsSubtopic

#pragma mark - AKSubtopic methods

- (NSString *)subtopicName
{
    return ([self includesAncestors]
            ? AKAllBindingsSubtopicName
            : AKBindingsSubtopicName);
}

#pragma mark - AKMembersSubtopic methods

- (NSArray *)memberTokensForBehavior:(AKBehaviorToken *)behaviorToken
{
    if ([behaviorToken isClassToken])
    {
        return [(AKClassToken *)behaviorToken documentedBindings];
    }
    else
    {
        return @[];
    }
}

+ (id)memberDocClass
{
    return [AKBindingDoc class];
}

@end
