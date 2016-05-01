//
//  AKPropertiesSubtopic.m
//  AppKiDo
//
//  Created by Andy Lee on 7/25/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKPropertiesSubtopic.h"

#import "AKClassItem.h"
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

- (NSArray *)memberItemsForBehavior:(AKBehaviorItem *)behaviorItem
{
    return [behaviorItem documentedProperties];
}

+ (id)memberDocClass
{
    return [AKPropertyDoc class];
}

@end
