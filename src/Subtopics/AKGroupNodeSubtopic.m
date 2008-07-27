/*
 * AKGroupNodeSubtopic.m
 *
 * Created by Andy Lee on Sun Mar 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKGroupNodeSubtopic.h"

#import <DIGSLog.h>

#import "AKFileSection.h"
#import "AKGlobalsNode.h"
#import "AKGroupNode.h"
#import "AKFileSectionDoc.h"

@implementation AKGroupNodeSubtopic

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithGroupNode:(AKGroupNode *)groupNode
{
    if ((self = [super init]))
    {
        _groupNode = [groupNode retain];
    }

    return self;
}

- (id)init
{
    DIGSLogNondesignatedInitializer();
    [self dealloc];
    return nil;
}

- (void)dealloc
{
    [_groupNode release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// AKSubtopic methods
//-------------------------------------------------------------------------

- (NSString *)subtopicName
{
    return [_groupNode nodeName];
}

- (void)populateDocList:(NSMutableArray *)docList
{
    NSEnumerator *en = [[_groupNode subnodes] objectEnumerator];
    AKGlobalsNode *globalsNode;

    while ((globalsNode = [en nextObject]))
    {
        AKDoc *newDoc =
            [[[AKFileSectionDoc alloc]
                initWithFileSection:[globalsNode nodeDocumentation]]
                autorelease];

        [docList addObject:newDoc];
    }
}

@end
