//
//  AKGlobalsGroupSubtopic.m
//  AppKiDo
//
//  Created by Andy Lee on 4/4/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKGlobalsGroupSubtopic.h"

#import "DIGSLog.h"

#import "AKFileSection.h"
#import "AKGlobalsDoc.h"
#import "AKGroupItem.h"
#import "AKSortUtils.h"

@implementation AKGlobalsGroupSubtopic

#pragma mark -
#pragma mark AKSubtopic methods

- (void)populateDocList:(NSMutableArray *)docList
{
    for (AKTokenItem *subitem in [AKSortUtils arrayBySortingArray:[self.groupItem subitems]])
    {
        AKDoc *newDoc = [[AKGlobalsDoc alloc] initWithNode:subitem];

        [docList addObject:newDoc];
    }
}

@end
