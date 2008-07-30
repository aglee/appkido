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

//-------------------------------------------------------------------------
// AKSubtopic methods
//-------------------------------------------------------------------------

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

//-------------------------------------------------------------------------
// AKMethodsSubtopic methods
//-------------------------------------------------------------------------

- (NSArray *)methodNodesForBehavior:(AKBehaviorNode *)behaviorNode
{
    return [behaviorNode documentedProperties];
}

+ (id)methodDocClass
{
    return [AKPropertyDoc class];
}

@end
