//
// AKDatabaseNode.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AKSortable.h"

@class AKFileSection;

/*!
 * @class       AKDatabaseNode
 * @abstract    Base class for entries in an AKDatabase.
 * @discussion  An AKDatabaseNode, or just "node," contains information
 *              about an OS X API construct.  Subclasses of AKDatabaseNode
 *              represent different types of construct such as frameworks,
 *              classes, and methods.
 *
 *              Each node has a nodeName attribute whose meaning depends on
 *              the type of programming construct represented.  For example,
 *              an AKClassNode's nodeName is the name of the class.  The
 *              nodeName is set by the node's init method and cannot be
 *              changed thereafter.
 *
 *              On init, each node is assigned a framework name indicating
 *              the framework that logically owns the node.  Nodes cannot
 *              change their owning frameworks.  The exception is an
 *              AKClassNode, which can belong to multiple frameworks and
 *              has a setter for indicating which of them is primary.
 *              is made via the framework name.
 *
 *              A node knows where to find the documentation for the
 *              construct it represents.  You can get the documentation by
 *              sending the node a -nodeDocumentation message.
 */
@interface AKDatabaseNode : NSObject <AKSortable>
{
@private
    NSString *_nodeName;
    NSString *_owningFramework;
    AKFileSection *_nodeDocumentation;
    BOOL _isDeprecated;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

/*!
 * @method      nodeWithNodeName:owningFramework:
 * @discussion  Returns an instance of the receiver containing the minimum
 *              information it needs to make sense.
 */
+ (id)nodeWithNodeName:(NSString *)nodeName
    owningFramework:(NSString *)fwName;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*!
 * @method      initWithNodeName:owningFramework:
 * @discussion  Designated initializer.
 */
- (id)initWithNodeName:(NSString *)nodeName
    owningFramework:(NSString *)fwName;

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

/*!
 * @method      nodeName
 * @discussion  The meaning of a node's nodeName depends on what kind of
 *              node it is.  For example, an AKClassNode's name is the
 *              name of the class, an AKMethodNode's name is the name of
 *              the method, etc.
 */
- (NSString *)nodeName;

/*!
 * @method      owningFramework
 * @discussion  Returns the name of the framework the node belongs to.
 *              Most nodes belong to exactly one framework.  The exception
 *              is AKClassNodes, which can belong to more than one.
 */
- (NSString *)owningFramework;

- (void)setOwningFramework:(NSString *)frameworkName;

/*!
 * @method      nodeDocumentation
 * @discussion  Returns a reference to the documentation for the API
 *              construct the node represents.  Possibly nil.
 */
- (AKFileSection *)nodeDocumentation;

/*!
 * @method      setNodeDocumentation:
 * @discussion  Tells the node where the documentation is for the API
 *              construct it represents.
 */
- (void)setNodeDocumentation:(AKFileSection *)fileSection;

- (BOOL)isDeprecated;
- (void)setIsDeprecated:(BOOL)isDeprecated;

//-------------------------------------------------------------------------
// AKSortable methods
//-------------------------------------------------------------------------

/*!
 * @method      sortName
 * @discussion  Returns the node name by default.
 */
- (NSString *)sortName;

@end
