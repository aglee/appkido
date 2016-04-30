//
// AKDocSetTokenItem.h
//
// Created by Andy Lee on Wed Jun 26 2002.
// Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DocSetModel.h"
#import "AKSortable.h"

@class AKDatabase;
@class AKFileSection;

/*!
 * Base class for entries in an AKDatabase.
 *
 * An AKDocSetTokenItem, or just "node," contains information about a Cocoa API
 * construct. Subclasses represent different types of constructs such as
 * frameworks, classes, and methods. Not all nodes are programming language
 * constructs.
 *
 * Nodes cannot normally change their owning frameworks.  The exception is an
 * AKClassNode, which can belong to multiple frameworks and has a setter for
 * indicating which of them is primary.
 *
 * A node may have documentation associated with it in the form of an
 * AKFileSection that contains HTML.
 */
@interface AKDocSetTokenItem : NSObject <AKSortable>
{
@private
    NSString *_nodeName;
    NSString *_nameOfOwningFramework;
    AKFileSection *_nodeDocumentation;
    BOOL _isDeprecated;
}

@property (nonatomic, strong) DSAToken *docSetToken;
@property (nonatomic, readonly, copy) NSString *nodeName;
@property (nonatomic, weak) AKDatabase *owningDatabase;

/*! Most nodes belong to exactly one framework. The exception is AKClassNode, because it can have categories that belong to other frameworks. */
@property (nonatomic, copy) NSString *nameOfOwningFramework;

/*! Documentation for the API construct the node represents. Possibly nil. */
@property (nonatomic, strong) AKFileSection *nodeDocumentation;

@property (nonatomic, assign) BOOL isDeprecated;

#pragma mark -
#pragma mark Factory methods

+ (instancetype)nodeWithNodeName:(NSString *)nodeName database:(AKDatabase *)database frameworkName:(NSString *)frameworkName;

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (instancetype)initWithNodeName:(NSString *)nodeName database:(AKDatabase *)database frameworkName:(NSString *)frameworkName NS_DESIGNATED_INITIALIZER;

@end
