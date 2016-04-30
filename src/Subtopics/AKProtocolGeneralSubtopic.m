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

+ (instancetype)subtopicForProtocolNode:(AKProtocolNode *)protocolNode
{
    return [[self alloc] initWithProtocolNode:protocolNode];
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithProtocolNode:(AKProtocolNode *)protocolNode
{
    if ((self = [super init]))
    {
        _protocolNode = protocolNode;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithProtocolNode:nil];
}


#pragma mark -
#pragma mark AKBehaviorGeneralSubtopic methods

- (AKBehaviorItem *)behaviorItem
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
