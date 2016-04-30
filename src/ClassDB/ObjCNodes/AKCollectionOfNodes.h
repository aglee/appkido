//
//  AKCollectionOfNodes.h
//  AppKiDo
//
//  Created by Andy Lee on 6/22/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AKDocSetTokenItem;

/*!
 * Wrapper around a collection of AKDocSetTokenItems, with a couple of convenience
 * methods.  Unlike an AKGroupNode, an AKCollectionOfNodes is not itself a node.
 */
@interface AKCollectionOfNodes : NSObject
{
@private
    // Contains all the AKDocSetTokenItems that have been added to us.
    NSMutableArray *_nodeList;

    // Keys are node names.  Values are AKDocSetTokenItems.
    NSMutableDictionary *_nodesByName;
}

#pragma mark -
#pragma mark Getters and setters

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *allNodes;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *nodesWithDocumentation;

- (AKDocSetTokenItem *)nodeWithName:(NSString *)nodeName;

- (void)addNode:(AKDocSetTokenItem *)datbaseNode;

@end
