/*
 * AKFunctionsSubtopic.m
 *
 * Created by Andy Lee on Sun May 30 2004.
 * Copyright (c) 2004 Andy Lee. All rights reserved.
 */

#import "AKFunctionsSubtopic.h"

#import "AKSortUtils.h"
#import "AKFileSection.h"
#import "AKGroupNode.h"
#import "AKFunctionDoc.h"

@implementation AKFunctionsSubtopic


#pragma mark -
#pragma mark AKSubtopic methods

- (void)populateDocList:(NSMutableArray *)docList
{
    NSEnumerator *subnodesEnum =
        [[AKSortUtils arrayBySortingArray:[_groupNode subnodes]]
            objectEnumerator];
    AKDatabaseNode *functionNode;

    while ((functionNode = [subnodesEnum nextObject]))
    {
        AKFileSection *functionSection = [functionNode nodeDocumentation];

        if (functionSection != nil)
        {
            AKDoc *newDoc =
                [[[AKFunctionDoc alloc] initWithNode:functionNode]
                    autorelease];
            
            [docList addObject:newDoc];
        }
    }
}

@end
