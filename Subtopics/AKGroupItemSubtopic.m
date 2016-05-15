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

#pragma mark - Init/awake/dealloc

- (instancetype)initWithGroupItem:(AKGroupItem *)groupItem
{
	self = [super init];
	if (self) {
		_groupItem = groupItem;
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithGroupItem:nil];
}

#pragma mark - AKSubtopic methods

- (NSString *)subtopicName
{
	return self.groupItem.name;
}

- (NSArray *)arrayWithDocListItems
{
	return [AKSortUtils arrayBySortingArray:self.groupItem.subitems];
}

@end
