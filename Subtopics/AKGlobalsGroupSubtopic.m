//
//  AKGlobalsGroupSubtopic.m
//  AppKiDo
//
//  Created by Andy Lee on 4/4/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKGlobalsGroupSubtopic.h"
#import "DIGSLog.h"
#import "AKGroupItem.h"
#import "AKSortUtils.h"

@implementation AKGlobalsGroupSubtopic

#pragma mark - AKSubtopic methods

- (void)populateDocList:(NSMutableArray *)docList
{
	[docList addObjectsFromArray:[AKSortUtils arrayBySortingArray:[self.groupItem subitems]]];
}

@end
