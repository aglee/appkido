/*
 * AKFunctionsGroupSubtopic.m
 *
 * Created by Andy Lee on Sun May 30 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKFunctionsGroupSubtopic.h"

#import "AKFileSection.h"
#import "AKFunctionDoc.h"
#import "AKGroupItem.h"
#import "AKSortUtils.h"

@implementation AKFunctionsGroupSubtopic

#pragma mark -
#pragma mark AKSubtopic methods

- (void)populateDocList:(NSMutableArray *)docList
{
    // Each subitem of a functions group item represents one function.
    for (AKTokenItem *functionItem in [AKSortUtils arrayBySortingArray:[self.groupItem subitems]])
    {
        AKFileSection *functionSection = functionItem.tokenItemDocumentation;

        if (functionSection != nil)
        {
            AKDoc *newDoc = [[AKFunctionDoc alloc] initWithTokenItem:functionItem];
            
            [docList addObject:newDoc];
        }
    }
}

@end
