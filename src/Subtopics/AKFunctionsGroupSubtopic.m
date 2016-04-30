/*
 * AKFunctionsGroupSubtopic.m
 *
 * Created by Andy Lee on Sun May 30 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKFunctionsGroupSubtopic.h"

#import "AKFileSection.h"
#import "AKFunctionDoc.h"
#import "AKGroupNode.h"
#import "AKSortUtils.h"

@implementation AKFunctionsGroupSubtopic

#pragma mark -
#pragma mark AKSubtopic methods

- (void)populateDocList:(NSMutableArray *)docList
{
    // Each subitem of a functions group item represents one function.
    for (AKDocSetTokenItem *functionNode in [AKSortUtils arrayBySortingArray:[self.groupNode subitems]])
    {
        AKFileSection *functionSection = functionNode.nodeDocumentation;

        if (functionSection != nil)
        {
            AKDoc *newDoc = [[AKFunctionDoc alloc] initWithNode:functionNode];
            
            [docList addObject:newDoc];
        }
    }
}

@end
