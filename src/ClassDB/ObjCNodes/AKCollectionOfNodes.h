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


#pragma mark -
#pragma mark Getters and setters

- (NSArray *)allNodes;

- (NSArray *)nodesWithDocumentation;

- (AKDatabaseNode *)nodeWithName:(NSString *)nodeName;

- (void)addNode:(AKDatabaseNode *)datbaseNode;

@end
