//
//  AKCollectionOfNodes.h
//  AppKiDo
//
//  Created by Andy Lee on 6/22/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AKDatabaseNode;

/*!
 * Wrapper around a collection of AKDatabaseNodes, with a couple of convenience
 * methods.  Unlike an AKGroupNode, an AKCollectionOfNodes is not itself a node.
 */
@interface AKCollectionOfNodes : NSObject
{
@private
    // Contains all the AKDatabaseNodes that have been added to us.
    NSMutableArray *_nodeList;

    // Keys are node names.  Values are AKDatabaseNodes.
    NSMutableDictionary *_nodesByName;
}

#pragma mark -
#pragma mark Getters and setters

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *allNodes;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *nodesWithDocumentation;

- (AKDatabaseNode *)nodeWithName:(NSString *)nodeName;

- (void)addNode:(AKDatabaseNode *)datbaseNode;

@end
