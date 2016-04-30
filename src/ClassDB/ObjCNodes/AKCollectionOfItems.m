//
//  AKCollectionOfItems.m
//  AppKiDo
//
//  Created by Andy Lee on 6/22/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKCollectionOfItems.h"

#import "DIGSLog.h"
#import "AKTokenItem.h"

@implementation AKCollectionOfItems

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)init
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

    for (AKTokenItem *tokenItem in _nodeList)
    {
        if (tokenItem.nodeDocumentation)
        {
            [result addObject:tokenItem];
        }
    }

    return result;
}

- (AKTokenItem *)nodeWithName:(NSString *)nodeName
{
    return _nodesByName[nodeName];
}

- (void)addNode:(AKTokenItem *)tokenItem
{
    NSString *nodeName = tokenItem.nodeName;

    if (_nodesByName[nodeName])
    {
        DIGSLogWarning(@"ignoring attempt to add node %@ twice", nodeName);
    }
    else
    {
        [_nodeList addObject:tokenItem];
        _nodesByName[nodeName] = tokenItem;
    }
}

@end
