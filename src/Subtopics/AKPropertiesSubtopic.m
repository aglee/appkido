//
//  AKPropertiesSubtopic.m
//  AppKiDo
//
//  Created by Andy Lee on 7/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKPropertiesSubtopic.h"

#import "AKClassNode.h"
#import "AKPropertyDoc.h"

@implementation AKPropertiesSubtopic


#pragma mark -
#pragma mark AKSubtopic methods

- (NSString *)subtopicName
{
    return
        [self includesAncestors]
        ? [@"ALL " stringByAppendingString:AKPropertiesSubtopicName]
        : AKPropertiesSubtopicName;
}

- (NSString *)stringToDisplayInSubtopicList
{
    return
        [self includesAncestors]
        ? [@"       " stringByAppendingString:[self subtopicName]]
        : [@"2.  " stringByAppendingString:[self subtopicName]];
}


#pragma mark -
#pragma mark AKMembersSubtopic methods

- (NSArray *)memberNodesForBehavior:(AKBehaviorNode *)behaviorNode
{
    return [behaviorNode documentedProperties];
}

+ (id)memberDocClass
{
    return [AKPropertyDoc class];
}

@end
