/*
 * AKDatabase.h
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class AKFileSection;
@class AKFramework;
@class AKClassNode;
@class AKProtocolNode;
@class AKFunctionNode;
@class AKGlobalsNode;
@class AKGroupNode;

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
{
@private
    // Elements are NSStrings, in the order in which the frameworks are
    // added to the database.  There are constants in AKFrameworkConstants.h
    // for the names of some frameworks that need to be treated specially.
    NSMutableArray *_frameworkNames;

    // --- Classes ---

    // (class name) -> (AKClassNode)
    NSMutableDictionary *_classNodesByName;

    // (framework name) -> (NSArray of AKClassNode)
    NSMutableDictionary *_classListsByFramework;

    // --- Protocols ---

    // (protocol name) -> (AKProtocolNodes)
    NSMutableDictionary *_protocolNodesByName;

    // (framework name) -> (NSArray of AKProtocolNode)
    NSMutableDictionary *_protocolListsByFramework;

    // --- Functions ---

    // (framework name) -> (NSArray of AKGroupNode)
    NSMutableDictionary *_functionsGroupListsByFramework;

    // (framework name) -> ((group name) -> AKGroupNode)
    NSMutableDictionary *_functionsGroupsByFrameworkAndGroup;

    // --- Globals ---

    // (framework name) -> (NSArray of AKGroupNode)
    NSMutableDictionary *_globalsGroupListsByFramework;

    // (framework name) -> ((group name) -> AKGroupNode)
    NSMutableDictionary *_globalsGroupsByFrameworkAndGroup;



    // --- KLUDGED HYPERLINK SUPPORT ---

    // Keys are path names of HTML doc files for classes.  Each value is
    // the AKClassNode for the class documented in that HTML file.
    NSMutableDictionary *_classNodesByHTMLFilePath;

    // Keys are path names of HTML doc files for protocols.  Each value is
    // the AKProtocolNode for the protocol documented in that HTML file.
    NSMutableDictionary *_protocolNodesByHTMLFilePath;

    // Keys are path names of HTML documentation files.  Each value is an
    // AKFileSection which is the root section for that file.  See
    // AKDocParser for an explanation of root sections.
    NSMutableDictionary *_rootSectionsByHTMLFilePath;

    // Keys are anchor strings.  Each value is a dictionary whose keys are
    // paths to HTML files and whose values are NSNumbers containing the
    // byte offset of that anchor within that file.
    //
    // See the comment for -offsetOfAnchorString:inHTMLFile: to see what
    // is meant by "anchor strings."
    NSMutableDictionary *_offsetsOfAnchorStringsInHTMLFiles;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

/*!
 * @method      defaultDatabase
 * @discussion  Returns a global instance.  This is merely a convenience;
 *              it's perfectly okay to create other instances.
 */
+ (AKDatabase *)defaultDatabase;

//-------------------------------------------------------------------------
// Getters and setters -- frameworks
//-------------------------------------------------------------------------

/*!
 * @method      frameworkNames
 * @discussion  Returns a list of framework names, in the order in which
 *              the frameworks were added.
 */
- (NSArray *)frameworkNames;

- (NSArray *)sortedFrameworkNames;

- (BOOL)hasFrameworkWithName:(NSString *)fwName;

//-------------------------------------------------------------------------
// Getters and setters -- classes
//-------------------------------------------------------------------------

- (NSArray *)classesForFramework:(NSString *)fwName;

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

- (AKClassNode *)classWithName:(NSString *)name;

/*!
 * @method      addClassNode:
 * @discussion  Does nothing if the receiver already contains a class
 *              with the same name.
 */
- (void)addClassNode:(AKClassNode *)classNode;

//-------------------------------------------------------------------------
// Getters and setters -- protocols
//-------------------------------------------------------------------------

- (NSArray *)formalProtocolsForFramework:(NSString *)fwName;

- (NSArray *)informalProtocolsForFramework:(NSString *)fwName;

/*!
 * @method      allProtocols
 * @discussion  Returns a list of all protocols known to the receiver, in
 *              no guaranteed order.
 */
- (NSArray *)allProtocols;

- (AKProtocolNode *)protocolWithName:(NSString *)name;

/*!
 * @method      addProtocolNode:
 * @discussion  Does nothing if the receiver already contains a protocol
 *              with the same name.
 */
- (void)addProtocolNode:(AKProtocolNode *)classNode;

//-------------------------------------------------------------------------
// Getters and setters -- functions
//-------------------------------------------------------------------------

- (int)numberOfFunctionsGroupsForFramework:(NSString *)fwName;
- (NSArray *)functionsGroupsForFramework:(NSString *)fwName;
- (AKGroupNode *)functionsGroupWithName:(NSString *)groupName
    inFramework:(NSString *)fwName;
- (void)addFunctionsGroup:(AKGroupNode *)functionsGroup;

//-------------------------------------------------------------------------
// Getters and setters -- globals
//-------------------------------------------------------------------------

- (int)numberOfGlobalsGroupsForFramework:(NSString *)fwName;
- (NSArray *)globalsGroupsForFramework:(NSString *)fwName;
- (AKGroupNode *)globalsGroupWithName:(NSString *)groupName
    inFramework:(NSString *)fwName;
- (void)addGlobalsGroup:(AKGroupNode *)globalsGroup;



//-------------------------------------------------------------------------
// Getters and setters -- hyperlink support
//-------------------------------------------------------------------------

- (AKClassNode *)classDocumentedInHTMLFile:(NSString *)htmlFilePath;
- (void)rememberThatClass:(AKClassNode *)classNode
    isDocumentedInHTMLFile:(NSString *)htmlFilePath;

- (AKProtocolNode *)protocolDocumentedInHTMLFile:(NSString *)htmlFilePath;
- (void)rememberThatProtocol:(AKProtocolNode *)protocolNode
    isDocumentedInHTMLFile:(NSString *)htmlFilePath;

- (AKFileSection *)rootSectionForHTMLFile:(NSString *)filePath;
- (void)rememberRootSection:(AKFileSection *)rootSection
    forHTMLFile:(NSString *)filePath;

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
- (int)offsetOfAnchorString:(NSString *)anchorString
    inHTMLFile:(NSString *)filePath;
- (void)rememberOffset:(int)anchorOffset
    ofAnchorString:(NSString *)anchorString
    inHTMLFile:(NSString *)filePath;

@end
