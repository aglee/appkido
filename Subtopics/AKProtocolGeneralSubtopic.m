/*
 * AKProtocolGeneralSubtopic.m
 *
 * Created by Andy Lee on Tue Jun 22 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKProtocolGeneralSubtopic.h"

#import "DIGSLog.h"
#import "AKProtocolItem.h"
#import "AKHTMLConstants.h"

@implementation AKProtocolGeneralSubtopic

#pragma mark -
#pragma mark Factory methods

+ (instancetype)subtopicForProtocolItem:(AKProtocolItem *)protocolItem
{
    return [[self alloc] initWithProtocolItem:protocolItem];
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithProtocolItem:(AKProtocolItem *)protocolItem
{
    if ((self = [super init]))
    {
        _protocolItem = protocolItem;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithProtocolItem:nil];
}


#pragma mark -
#pragma mark AKBehaviorGeneralSubtopic methods

- (AKBehaviorItem *)behaviorItem
{
    return _protocolItem;
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
