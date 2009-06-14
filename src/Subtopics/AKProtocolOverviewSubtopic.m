/*
 * AKProtocolOverviewSubtopic.m
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKProtocolOverviewSubtopic.h"

#import "DIGSLog.h"

#import "AKProtocolNode.h"

#import "AKHTMLConstants.h"

@implementation AKProtocolOverviewSubtopic

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)subtopicForProtocolNode:(AKProtocolNode *)protocolNode
{
    return [[[self alloc] initWithProtocolNode:protocolNode] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithProtocolNode:(AKProtocolNode *)protocolNode
{
    if ((self = [super init]))
    {
        _protocolNode = [protocolNode retain];
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    [self release];
    return nil;
}

- (void)dealloc
{
    [_protocolNode release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// AKBehaviorOverviewSubtopic methods
//-------------------------------------------------------------------------

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
