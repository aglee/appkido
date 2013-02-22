/*
 * AKDatabase.h
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import "AKDatabaseDelegate.h"

@class AKClassNode;
@class AKDatabaseNode;
@class AKDocSetIndex;
@class AKFileSection;
@class AKFramework;
@class AKFunctionNode;
@class AKGlobalsNode;
@class AKGroupNode;
@class AKProtocolNode;

// [agl] TODO -- Should explain distinction between a node and a token.  A
// node can map to multiple tokens.  For example a globals node for an enum
// maps to all the items in the enum, and a group node contains multiple
// subnodes.


// [agl] TODO -- The class comment has to be rewritten.  It's up to
// subclasses to *populate* the ivars in the abstract class via the
// -populateDatabase method, which needs to be called after instantiating
// the database and before trying to use it.  Also, there should be no more default
// database.  Also, mention the delegate.  Also, this is now a class cluster.

/*!
 * @class       AKDatabase
 * @abstract    In-memory database of API constructs and their
 *              documentation.
 * @discussion  An AKDatabase contains information about the APIs for OS X
 *              frameworks such as Foundation and AppKit.  This information
 *              consists of (1) the names and logical relationships between
 *              API constructs (for example, "the Foundation class NSString
 *              is a subclass of NSObject"); (2) HTML documentation for the
 *              API; and (3) bookkeeping information that supports
 *              navigation of the documentation.
 *
 *              Each framework in an AKDatabase is represented by a concrete
 *              instance of AKFramework.  Different frameworks have
 *              different ways of organizing their APIs and the associated
 *              documentation.  These differences are managed by subclasses
 *              of AKFramework.
 *
 *              Within a framework, individual API constructs are
 *              represented by objects called "nodes."  Nodes are instances
 *              of AKDatabaseNode and its descendant classes such as
 *              AKClassNode and AKMethodNode.  Nodes in one framework
 *              frequently refer to nodes in another framework -- for
 *              example, when an AppKit class inherits from a Foundation
 *              class.  The database can be thought of as a wrapper around
 *              a graph of database nodes that are grouped by framework.
 *
 *              In theory you are free to create multiple instances of
 *              AKDatabase.  AppKiDo only uses the global shared instance,
 *              which is referred to throughout the AppKiDo documentation as
 *              "the database."
 */
@interface AKDatabase : NSObject

@property (nonatomic, weak) id <AKDatabaseDelegate>delegate;
@property (nonatomic, readonly, strong) AKDocSetIndex *docSetIndex;


#pragma mark -
#pragma mark - Factory methods

/*! On failure, returns nil with the reasons added to errorStrings. */
+ (id)databaseForMacPlatformWithErrorStrings:(NSMutableArray *)errorStrings;

/*! On failure, returns nil with the reasons added to errorStrings. */
+ (id)databaseForIPhonePlatformWithErrorStrings:(NSMutableArray *)errorStrings;


#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithDocSetIndex:(AKDocSetIndex *)docSetIndex;


#pragma mark -
#pragma mark Populating the database

/*!
 * For each given framework names, queries the docSetIndex for all API tokens in
 * the that framework. Adds database nodes accordingly. Sends a delegate message
 * for each framework loaded.
 *
 * If frameworkNames is nil, all "essential" frameworks are loaded. The meaning
 * "essential" depends on the platform the database is for.
 */
- (void)loadTokensForFrameworksWithNames:(NSArray *)frameworkNames;


#pragma mark -
#pragma mark Getters and setters -- frameworks

- (void)addFrameworkName:(NSString *)frameworkName;

/*! Names of all frameworks that have been loaded, in no guaranteed order. */
- (NSArray *)frameworkNames;

/*! Same as -frameworkNames, but sorted alphabetically. */
- (NSArray *)sortedFrameworkNames;

- (BOOL)hasFrameworkWithName:(NSString *)frameworkName;

/*! Names of all frameworks we can offer for the user to load. */
- (NSArray *)namesOfAvailableFrameworks;


#pragma mark -
#pragma mark Getters and setters -- classes

/*! Array of AKClassNode. No guaranteed order. */
- (NSArray *)classesForFrameworkNamed:(NSString *)frameworkName;

/*! * Class without parent class. Array of AKClassNode. No guaranteed order. */
- (NSArray *)rootClasses;

/*! Array of AKClassNode. No guaranteed order. */
- (NSArray *)allClasses;

- (AKClassNode *)classWithName:(NSString *)className;

/*! Does nothing if we already contain a class with that name. */
- (void)addClassNode:(AKClassNode *)classNode;


#pragma mark -
#pragma mark Getters and setters -- protocols

/*! Array of AKProtocolNode. No guaranteed order. */
- (NSArray *)formalProtocolsForFrameworkNamed:(NSString *)frameworkName;

/*! Array of AKProtocolNode. No guaranteed order. */
- (NSArray *)informalProtocolsForFrameworkNamed:(NSString *)frameworkName;

/*! Array of AKProtocolNode. No guaranteed order. */
- (NSArray *)allProtocols;

- (AKProtocolNode *)protocolWithName:(NSString *)name;

/*! Does nothing if we already contain a protocol with that name. */
- (void)addProtocolNode:(AKProtocolNode *)classNode;


#pragma mark -
#pragma mark Getters and setters -- functions

- (NSInteger)numberOfFunctionsGroupsForFrameworkNamed:(NSString *)frameworkName;

- (NSArray *)functionsGroupsForFrameworkNamed:(NSString *)frameworkName;

- (AKGroupNode *)functionsGroupNamed:(NSString *)groupName
                    inFrameworkNamed:(NSString *)frameworkName;

- (void)addFunctionsGroup:(AKGroupNode *)functionsGroup;

- (AKGroupNode *)functionsGroupContainingFunctionNamed:(NSString *)functionName
                                      inFrameworkNamed:(NSString *)frameworkName;


#pragma mark -
#pragma mark Getters and setters -- globals

- (NSInteger)numberOfGlobalsGroupsForFrameworkNamed:(NSString *)frameworkName;

- (NSArray *)globalsGroupsForFrameworkNamed:(NSString *)frameworkName;

- (AKGroupNode *)globalsGroupNamed:(NSString *)groupName
                  inFrameworkNamed:(NSString *)frameworkName;

- (void)addGlobalsGroup:(AKGroupNode *)globalsGroup;

- (AKGroupNode *)globalsGroupContainingGlobalNamed:(NSString *)nameOfGlobal
                                  inFrameworkNamed:(NSString *)frameworkName;


#pragma mark -
#pragma mark Getters and setters -- hyperlink support

- (NSString *)frameworkForHTMLFile:(NSString *)htmlFilePath;

- (void)rememberFrameworkName:(NSString *)frameworkName forHTMLFile:(NSString *)htmlFilePath;

- (AKClassNode *)classDocumentedInHTMLFile:(NSString *)htmlFilePath;
- (void)rememberThatClass:(AKClassNode *)classNode isDocumentedInHTMLFile:(NSString *)htmlFilePath;

- (AKProtocolNode *)protocolDocumentedInHTMLFile:(NSString *)htmlFilePath;
- (void)rememberThatProtocol:(AKProtocolNode *)protocolNode isDocumentedInHTMLFile:(NSString *)htmlFilePath;

- (AKFileSection *)rootSectionForHTMLFile:(NSString *)filePath;
- (void)rememberRootSection:(AKFileSection *)rootSection forHTMLFile:(NSString *)filePath;

// [agl] Awkward having these here. Rethink design. Separate concerns between
// the node graph and the documentation repository.
/*!
 * @method      offsetOfAnchorString:inHTMLFile:
 * @discussion  When the user clicks a hyperlink, we are given the name of
 *              an HTML file and an "anchor string" that indicates where
 *              in that file we should link to.
 *
 *              In HTML terms, the anchor string is the value of the "name"
 *              attribute in a tag of the form <a name="xxx">.
 *
 *              This method returns the byte offset of the given anchor
 *              string within the given file, or -1 if it is not present.
 */
- (NSInteger)offsetOfAnchorString:(NSString *)anchorString
                       inHTMLFile:(NSString *)filePath;
- (void)rememberOffset:(NSInteger)anchorOffset
        ofAnchorString:(NSString *)anchorString
            inHTMLFile:(NSString *)filePath;


@end


