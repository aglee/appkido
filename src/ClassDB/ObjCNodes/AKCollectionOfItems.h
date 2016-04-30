//
//  AKCollectionOfItems.h
//  AppKiDo
//
//  Created by Andy Lee on 6/22/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AKTokenItem;

/*!
 * Wrapper around a collection of AKTokenItems, with a couple of convenience
 * methods.  Unlike an AKGroupItem, an AKCollectionOfItems is not itself a node.
 */
@interface AKCollectionOfItems : NSObject
{
@private
    // Contains all the AKTokenItems that have been added to us.
    NSMutableArray *_nodeList;

    // Keys are node names.  Values are AKTokenItems.
    NSMutableDictionary *_nodesByName;
}

#pragma mark -
#pragma mark Getters and setters

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *allNodes;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *nodesWithDocumentation;

- (AKTokenItem *)nodeWithName:(NSString *)nodeName;

- (void)addNode:(AKTokenItem *)datbaseNode;

@end
