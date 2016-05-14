/*
 * AKFunctionsGroupSubtopic.m
 *
 * Created by Andy Lee on Sun May 30 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKFunctionsGroupSubtopic.h"
#import "AKGroupItem.h"
#import "AKSortUtils.h"

@implementation AKFunctionsGroupSubtopic

#pragma mark - AKSubtopic methods

- (void)populateDocList:(NSMutableArray *)docList
{
	[docList addObjectsFromArray:[AKSortUtils arrayBySortingArray:[self.groupItem subitems]]];
}

@end
