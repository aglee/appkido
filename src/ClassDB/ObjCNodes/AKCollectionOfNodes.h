//
//  AKCollectionOfNodes.h
//  AppKiDo
//
//  Created by Andy Lee on 6/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AKDatabaseNode;

/*!
 * Wrapper around a collection of AKDatabaseNodes, with a couple of convenience
 * methods.  Unlike an AKGroupNode, an AKCollectionOfNodes is not itself a node.
 */
@interface AKCollectionOfNodes : NSObject
{
    // Contains all the AKDatabaseNodes that have been added to us.
    NSMutableArray *_nodeList;

    // Keys are method names.  Values are AKDatabaseNodes.
    NSMutableDictionary *_nodesByName;
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSArray *)allNodes;

- (NSArray *)nodesWithDocumentation;

- (AKDatabaseNode *)nodeWithName:(NSString *)nodeName;

- (void)addNode:(AKDatabaseNode *)datbaseNode;

@end
