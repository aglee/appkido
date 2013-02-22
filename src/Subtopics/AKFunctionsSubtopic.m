/*
 * AKFunctionsSubtopic.m
 *
 * Created by Andy Lee on Sun May 30 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKFunctionsSubtopic.h"

#import "AKFileSection.h"
#import "AKFunctionDoc.h"
#import "AKGroupNode.h"
#import "AKSortUtils.h"

@implementation AKFunctionsSubtopic


#pragma mark -
#pragma mark AKSubtopic methods

- (void)populateDocList:(NSMutableArray *)docList
{
    for (AKDatabaseNode *functionNode in [AKSortUtils arrayBySortingArray:[_groupNode subnodes]])
    {
        AKFileSection *functionSection = [functionNode nodeDocumentation];

        if (functionSection != nil)
        {
            AKDoc *newDoc = [[AKFunctionDoc alloc] initWithNode:functionNode];
            
            [docList addObject:newDoc];
        }
    }
}

@end
