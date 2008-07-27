//
//  AKCollectionOfNodes.m
//  AppKiDo
//
//  Created by Andy Lee on 6/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKCollectionOfNodes.h"

#import "DIGSLog.h"
#import "AKDatabaseNode.h"

@implementation AKCollectionOfNodes

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)init
{
    if ((self = [super init]))
    {
        _nodeList = [[NSMutableArray alloc] init];
        _nodesByName = [[NSMutableDictionary alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [_nodeList release];
    [_nodesByName release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSArray *)allNodes
{
    return _nodeList;
}

- (NSArray *)nodesWithDocumentation
{
    NSMutableArray *result = [NSMutableArray array];
    NSEnumerator *en = [_nodeList objectEnumerator];
    AKDatabaseNode *databaseNode;

    while ((databaseNode = [en nextObject]))
    {
        if ([databaseNode nodeDocumentation])
        {
            [result addObject:databaseNode];
        }
    }

    return result;
}

- (AKDatabaseNode *)nodeWithName:(NSString *)nodeName
{
    return [_nodesByName objectForKey:nodeName];
}

- (void)addNode:(AKDatabaseNode *)databaseNode
{
    NSString *nodeName = [databaseNode nodeName];

    if ([_nodesByName objectForKey:nodeName])
    {
        DIGSLogWarning(@"ignoring attempt to add node %@ twice", nodeName);
    }
    else
    {
        [_nodeList addObject:databaseNode];
        [_nodesByName setObject:databaseNode forKey:nodeName];
    }
}

@end
