/*
 * AKBehaviorGeneralSubtopic.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorGeneralSubtopic.h"
#import "DIGSLog.h"
#import "AKClassItem.h"
#import "AKHeaderFileDoc.h"

@implementation AKBehaviorGeneralSubtopic

#pragma mark - Getters and setters

- (AKBehaviorToken *)behaviorToken
{
    DIGSLogError_MissingOverride();
    return nil;
}

#pragma mark - AKSubtopic methods

- (NSString *)subtopicName
{
    return AKGeneralSubtopicName;
}

- (NSString *)stringToDisplayInSubtopicList
{
    return [self subtopicName];
}

- (void)populateDocList:(NSMutableArray *)docList
{
    AKHeaderFileDoc *headerFileDoc = [[AKHeaderFileDoc alloc] initWithToken:self.behaviorToken];
    [docList addObject:headerFileDoc];
}

@end
