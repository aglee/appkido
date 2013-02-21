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
 * @method      frameworkNameIsSelectable:
 * @discussion  Is there a framework with the given name on the receiver's platform?
 */
- (BOOL)frameworkNameIsSelectable:(NSString *)frameworkName;

/*!
 * @method      loadTokensForFrameworks:
 * @discussion  Sends delegate message for each
 *              framework loaded.  frameworkNames can be nil; by default, this causes
 *              all "essential" frameworks to be loaded.
 */
- (void)loadTokensForFrameworks:(NSArray *)frameworkNames;


#pragma mark -
#pragma mark Getters and setters

- (AKDocSetIndex *)docSetIndex;

/*!
 * @method      setDelegate:
 * @discussion  The delegate is notified when a framework is about to be loaded.
 */
- (void)setDelegate:(id <AKDatabaseDelegate>)delegate;


#pragma mark -
#pragma mark Getters and setters -- frameworks

/*
 * @method      frameworkWithName:
 * @discussion  Creates the AKFramework instance if it doesn't exist. [agl] Possibly confusing? Not sure.
 */
- (AKFramework *)frameworkWithName:(NSString *)frameworkName;

/*!
 * @method      frameworkNames
 * @discussion  Returns the names of all frameworks that have been loaded, in no guaranteed order.
 */
- (NSArray *)frameworkNames;

- (NSArray *)sortedFrameworkNames;

- (BOOL)hasFrameworkWithName:(NSString *)frameworkName;

- (NSArray *)namesOfAvailableFrameworks;


#pragma mark -
#pragma mark Getters and setters -- classes

/*!
 * @method      classesForFrameworkNamed:
 * @discussion  Elements of the returned array are AKClassNodes.  Order is undefined.
 */
- (NSArray *)classesForFrameworkNamed:(NSString *)frameworkName;

/*!
 * @method      rootClasses
 * @discussion  Returns all classes that have no parent class.  Elements of
 *              the returned array are AKClassNodes.  Order is undefined.
 */
- (NSArray *)rootClasses;

/*!
 * @method      allClasses
 * @discussion  Returns all classes known to the receiver.  Elements of
 *              the returned array are AKClassNodes.  Order is undefined.
 */
- (NSArray *)allClasses;

- (AKClassNode *)classWithName:(NSString *)className;

/*!
 * @method      addClassNode:
 * @discussion  Does nothing if the receiver already contains a class with the same name.
 */
- (void)addClassNode:(AKClassNode *)classNode;


#pragma mark -
#pragma mark Getters and setters -- protocols

- (NSArray *)formalProtocolsForFrameworkNamed:(NSString *)frameworkName;

- (NSArray *)informalProtocolsForFrameworkNamed:(NSString *)frameworkName;

/*!
 * @method      allProtocols
 * @discussion  Returns a list of all protocols known to the receiver, in no guaranteed order.
 */
- (NSArray *)allProtocols;

- (AKProtocolNode *)protocolWithName:(NSString *)name;

/*!
 * @method      addProtocolNode:
 * @discussion  Does nothing if the receiver already contains a protocol with the same name.
 */
- (void)addProtocolNode:(AKProtocolNode *)classNode;


#pragma mark -
#pragma mark Getters and setters -- functions

- (NSInteger)numberOfFunctionsGroupsForFrameworkNamed:(NSString *)frameworkName;
- (NSArray *)functionsGroupsForFrameworkNamed:(NSString *)frameworkName;
- (AKGroupNode *)functionsGroupNamed:(NSString *)groupName inFrameworkNamed:(NSString *)frameworkName;
- (void)addFunctionsGroup:(AKGroupNode *)functionsGroup;

- (AKGroupNode *)functionsGroupContainingFunctionNamed:(NSString *)functionName
                                      inFrameworkNamed:(NSString *)frameworkName;


#pragma mark -
#pragma mark Getters and setters -- globals

- (NSInteger)numberOfGlobalsGroupsForFrameworkNamed:(NSString *)frameworkName;
- (NSArray *)globalsGroupsForFrameworkNamed:(NSString *)frameworkName;
- (AKGroupNode *)globalsGroupNamed:(NSString *)groupName inFrameworkNamed:(NSString *)frameworkName;
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


