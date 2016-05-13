//
//  AKPropertiesSubtopic.m
//  AppKiDo
//
//  Created by Andy Lee on 7/25/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKPropertiesSubtopic.h"

#import "AKClassToken.h"
#import "AKPropertyDoc.h"

@implementation AKPropertiesSubtopic

#pragma mark - AKSubtopic methods

- (NSString *)subtopicName
{
    return ([self includesAncestors]
            ? AKAllPropertiesSubtopicName
            : AKPropertiesSubtopicName);
}

- (NSString *)stringToDisplayInSubtopicList
{
    return ([self includesAncestors]
            ? [@"       " stringByAppendingString:[self subtopicName]]
            : [self subtopicName]);
}

#pragma mark - AKMembersSubtopic methods

- (NSArray *)memberItemsForBehavior:(AKBehaviorToken *)behaviorToken
{
    return [behaviorToken propertyItems];
}

+ (id)memberDocClass
{
    return [AKPropertyDoc class];
}

@end
