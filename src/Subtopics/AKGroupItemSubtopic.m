/*
 * AKGroupItemSubtopic.m
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKGroupItemSubtopic.h"

#import "AKGroupItem.h"

@implementation AKGroupItemSubtopic

@synthesize groupItem = _groupItem;

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithGroupItem:(AKGroupItem *)groupItem
{
    if ((self = [super init]))
    {
        _groupItem = groupItem;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithGroupItem:nil];
}


#pragma mark -
#pragma mark AKSubtopic methods

- (NSString *)subtopicName
{
    return _groupItem.tokenName;
}

@end
