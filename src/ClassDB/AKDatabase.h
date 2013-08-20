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
@class AKFunctionNode;
@class AKGlobalsNode;
@class AKGroupNode;
@class AKProtocolNode;

/*!
 * Contains information about a Cocoa-style Objective-C API: the names of API
 * constructs, the logical relationships between them, and where each one is
 * documented. An example of a fact in this database is "The Foundation
 * class NSString is a subclass of NSObject, and is documented in file XYZ."
 *
 * All this information is represented as a graph of AKDatabaseNode objects.
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
    AKDocSetIndex *_docSetIndex;
    id <AKDatabaseDelegate> _delegate;
    
    // Frameworks.
    // Note: there are constants in AKFrameworkConstants.h for the names of some
    // frameworks that need to be treated specially.
    NSMutableArray *_frameworkNames;
    NSMutableArray *_namesOfAvailableFrameworks;

    // Classes.
    NSMutableDictionary *_classNodesByName;  // @{CLASS_NAME: AKClassNode}

    // Protocol.
    NSMutableDictionary *_protocolNodesByName;  // @{PROTOCOL_NAME -> @[AKProtocolNode]

    // Functions.
    NSMutableDictionary *_functionsGroupListsByFramework;  // @{FRAMEWORK_NAME: @[AKGroupNode]}
    NSMutableDictionary *_functionsGroupsByFrameworkAndGroup;  // @{FRAMEWORK_NAME: @{GROUP_NAME: AKGroupNode}}

    // Globals.
    NSMutableDictionary *_globalsGroupListsByFramework;  // @{FRAMEWORK_NAME: @[AKGroupNode]}
    NSMutableDictionary *_globalsGroupsByFrameworkAndGroup;  // @{FRAMEWORK_NAME: @{GROUP_NAME: AKGroupNode}}

    // Hyperlink support.
    NSMutableDictionary *_classNodesByHTMLPath;  // @{PATH_TO_HTML_FILE: AKClassNode}
    NSMutableDictionary *_protocolNodesByHTMLPath;  // @{PATH_TO_HTML_FILE: AKProtocolNode}
}

@property (nonatomic, unsafe_unretained) id <AKDatabaseDelegate> delegate;

#pragma mark -
#pragma mark Factory methods

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

/*! Names of all frameworks that have been loaded, in no guaranteed order. */
- (NSArray *)frameworkNames;

/*! Same as -frameworkNames, but sorted alphabetically. */
- (NSArray *)sortedFrameworkNames;

- (BOOL)hasFrameworkWithName:(NSString *)frameworkName;

/*! Names of all frameworks we can offer for the user to load. */
- (NSArray *)namesOfAvailableFrameworks;

#pragma mark -
#pragma mark Getters and setters -- classes

/*! Array of AKClassNode. Matches any of the class's owning frameworks. */
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

- (NSArray *)functionsGroupsForFrameworkNamed:(NSString *)frameworkName;
- (AKGroupNode *)functionsGroupNamed:(NSString *)groupName
                    inFrameworkNamed:(NSString *)frameworkName;
- (void)addFunctionsGroup:(AKGroupNode *)functionsGroup;

#pragma mark -
#pragma mark Getters and setters -- globals

- (NSArray *)globalsGroupsForFrameworkNamed:(NSString *)frameworkName;
- (AKGroupNode *)globalsGroupNamed:(NSString *)groupName
                  inFrameworkNamed:(NSString *)frameworkName;
- (void)addGlobalsGroup:(AKGroupNode *)globalsGroup;

#pragma mark -
#pragma mark Methods that help AKCocoaGlobalsDocParser

- (AKClassNode *)classDocumentedInHTMLFile:(NSString *)htmlFilePath;
- (void)rememberThatClass:(AKClassNode *)classNode isDocumentedInHTMLFile:(NSString *)htmlFilePath;

- (AKProtocolNode *)protocolDocumentedInHTMLFile:(NSString *)htmlFilePath;
- (void)rememberThatProtocol:(AKProtocolNode *)protocolNode isDocumentedInHTMLFile:(NSString *)htmlFilePath;

@end
