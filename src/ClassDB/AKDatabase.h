/*
 * AKDatabase.h
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "DocSetIndex.h"
#import "DocSetModel.h"

@class AKClassItem;
@class AKTokenItem;
@class AKFunctionItem;
@class AKGlobalsItem;
@class AKGroupItem;
@class AKProtocolItem;

/*!
 * Contains information about a Cocoa-style Objective-C API: the names of API
 * constructs, the logical relationships between them, and where each one is
 * documented. An example of a fact in this database is "The Foundation
 * class NSString is a subclass of NSObject, and is documented in file XYZ."
 *
 * All this information is represented as a graph of AKTokenItem objects.
 * Every query to this database returns a collection of database nodes.
 *
 * Before querying a database, you need to populate it by calling
 * loadTokensForFrameworksWithNames:. You can set a delegate which will be
 * messaged at various points while the database is being populated.
 *
 * An AKDatabase lives entirely in memory. There is currently no option to use a
 * persistent store.
 */
@interface AKDatabase : NSObject
{
@private
    // Frameworks.
    NSArray *_frameworkNames;

    // Protocol.
    NSMutableDictionary *_protocolItemsByName;  // @{PROTOCOL_NAME -> @[AKProtocolItem]

    // Functions.
    NSMutableDictionary *_functionsGroupListsByFramework;  // @{FRAMEWORK_NAME: @[AKGroupItem]}
    NSMutableDictionary *_functionsGroupsByFrameworkAndGroup;  // @{FRAMEWORK_NAME: @{GROUP_NAME: AKGroupItem}}

    // Globals.
    NSMutableDictionary *_globalsGroupListsByFramework;  // @{FRAMEWORK_NAME: @[AKGroupItem]}
    NSMutableDictionary *_globalsGroupsByFrameworkAndGroup;  // @{FRAMEWORK_NAME: @{GROUP_NAME: AKGroupItem}}

    // Hyperlink support.
    NSMutableDictionary *_classItemsByHTMLPath;  // @{PATH_TO_HTML_FILE: AKClassItem}
    NSMutableDictionary *_protocolItemsByHTMLPath;  // @{PATH_TO_HTML_FILE: AKProtocolItem}
}

@property (NS_NONATOMIC_IOSONLY, readonly, strong) DocSetIndex *docSetIndex;

/*! Names of all frameworks that have been loaded, in no guaranteed order. */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *frameworkNames;

/*! Same as .frameworkNames, but sorted alphabetically. */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *sortedFrameworkNames;

/*! Array of AKClassItem. No guaranteed order. Each element represents a class that does not have a superclass. */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *rootClasses;

/*! Array of AKClassItem. No guaranteed order. */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *allClasses;

/*! Array of AKProtocolItem. No guaranteed order. */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *allProtocols;

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithDocSetIndex:(DocSetIndex *)docSetIndex NS_DESIGNATED_INITIALIZER;

#pragma mark -
#pragma mark Populating the database

/*! Populates the database using contents of the DocSetIndex. */
- (void)populate;

#pragma mark -
#pragma mark Getters and setters -- frameworks

- (BOOL)hasFrameworkWithName:(NSString *)frameworkName;

#pragma mark -
#pragma mark Getters and setters -- classes

/*! Array of AKClassItem. Matches any of the class's owning frameworks. */
- (NSArray *)classesForFrameworkNamed:(NSString *)frameworkName;

- (AKClassItem *)classWithName:(NSString *)className;

#pragma mark -
#pragma mark Getters and setters -- protocols

/*! Array of AKProtocolItem. No guaranteed order. */
- (NSArray *)formalProtocolsForFrameworkNamed:(NSString *)frameworkName;

/*! Array of AKProtocolItem. No guaranteed order. */
- (NSArray *)informalProtocolsForFrameworkNamed:(NSString *)frameworkName;

- (AKProtocolItem *)protocolWithName:(NSString *)name;

/*! Does nothing if we already contain a protocol with that name. */
- (void)addProtocolItem:(AKProtocolItem *)protocolItem;

#pragma mark -
#pragma mark Getters and setters -- functions

- (NSArray *)functionsGroupsForFrameworkNamed:(NSString *)frameworkName;
- (AKGroupItem *)functionsGroupNamed:(NSString *)groupName
                    inFrameworkNamed:(NSString *)frameworkName;
- (void)addFunctionsGroup:(AKGroupItem *)functionsGroup;

#pragma mark -
#pragma mark Getters and setters -- globals

- (NSArray *)globalsGroupsForFrameworkNamed:(NSString *)frameworkName;
- (AKGroupItem *)globalsGroupNamed:(NSString *)groupName
                  inFrameworkNamed:(NSString *)frameworkName;
- (void)addGlobalsGroup:(AKGroupItem *)globalsGroup;

#pragma mark -
#pragma mark Methods that help AKCocoaGlobalsDocParser

- (AKClassItem *)classDocumentedInHTMLFile:(NSString *)htmlFilePath;
- (void)rememberThatClass:(AKClassItem *)classItem isDocumentedInHTMLFile:(NSString *)htmlFilePath;

- (AKProtocolItem *)protocolDocumentedInHTMLFile:(NSString *)htmlFilePath;
- (void)rememberThatProtocol:(AKProtocolItem *)protocolItem isDocumentedInHTMLFile:(NSString *)htmlFilePath;

@end
