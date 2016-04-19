/*
 * AKProtocolGeneralSubtopic.m
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKProtocolGeneralSubtopic.h"

#import "DIGSLog.h"
#import "AKProtocolNode.h"
#import "AKHTMLConstants.h"

@implementation AKProtocolGeneralSubtopic

#pragma mark -
#pragma mark Factory methods

+ (id)subtopicForProtocolNode:(AKProtocolNode *)protocolNode
{
    return [[self alloc] initWithProtocolNode:protocolNode];
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithProtocolNode:(AKProtocolNode *)protocolNode
{
    if ((self = [super init]))
    {
        _protocolNode = protocolNode;
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}


#pragma mark -
#pragma mark AKBehaviorGeneralSubtopic methods

- (AKBehaviorNode *)behaviorNode
{
    return _protocolNode;
}

- (NSString *)htmlNameOfDescriptionSection
{
    return AKProtocolDescriptionHTMLSectionName;
}

- (NSString *)altHtmlNameOfDescriptionSection
{
    return AKProtocolDescriptionAlternateHTMLSectionName;
}

@end
