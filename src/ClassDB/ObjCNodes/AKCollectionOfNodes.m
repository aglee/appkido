//
//  AKCollectionOfNodes.m
//  AppKiDo
//
//  Created by Andy Lee on 6/22/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKCollectionOfNodes.h"

#import "DIGSLog.h"
#import "AKDatabaseNode.h"

@implementation AKCollectionOfNodes
{
    // Contains all the AKDatabaseNodes that have been added to us.
    NSMutableArray *_nodeList;

    // Keys are node names.  Values are AKDatabaseNodes.
    NSMutableDictionary *_nodesByName;
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)init
{
    if ((self = [super init]))
    {
        _nodeList = [[NSMutableArray alloc] init];
        _nodesByName = [[NSMutableDictionary alloc] init];
    }

    return self;
}



#pragma mark -
#pragma mark Getters and setters

- (NSArray *)allNodes
{
    return _nodeList;
}

- (NSArray *)nodesWithDocumentation
{
    NSMutableArray *result = [NSMutableArray array];

    for (AKDatabaseNode *databaseNode in _nodeList)
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
