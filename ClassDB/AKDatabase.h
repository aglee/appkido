/*
 * AKDatabase.h
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "DocSetIndex.h"
#import "DocSetModel.h"

@class AKClassToken;
@class AKToken;
@class AKFunctionToken;
@class AKGroupItem;
@class AKProtocolToken;

/*!
 * Contains information about a Cocoa-style Objective-C API: the names of API
 * constructs, the logical relationships between them, and where each one is
 * documented. An example of a fact in this database is "The Foundation
 * class NSString is a subclass of NSObject, and is documented in file XYZ."
 *
 * All this information is represented as a graph of AKToken objects.
 * Every query to this database returns a collection of database items.
 *
 * Before querying a database, you need to populate it by calling -populate.
 * You can set a delegate which will be messaged at various points while the
 * database is being populated.
 *
 * An AKDatabase lives entirely in memory and is currently constructed from
 * scratch at launch.
 */
@interface AKDatabase : NSObject
{
@private
    // Functions.
    NSMutableDictionary *_functionsGroupListsByFramework;  // @{FRAMEWORK_NAME: @[AKGroupItem]}
    NSMutableDictionary *_functionsGroupsByFrameworkAndGroup;  // @{FRAMEWORK_NAME: @{GROUP_NAME: AKGroupItem}}

    // Globals.
    NSMutableDictionary *_globalsGroupListsByFramework;  // @{FRAMEWORK_NAME: @[AKGroupItem]}
    NSMutableDictionary *_globalsGroupsByFrameworkAndGroup;  // @{FRAMEWORK_NAME: @{GROUP_NAME: AKGroupItem}}
}

@property (NS_NONATOMIC_IOSONLY, readonly, strong) DocSetIndex *docSetIndex;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *frameworkNames;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *sortedFrameworkNames;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *rootClasses;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *allClasses;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *allProtocols;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDocSetIndex:(DocSetIndex *)docSetIndex NS_DESIGNATED_INITIALIZER;

#pragma mark - Populating the database

/*! Populates the database using contents of the DocSetIndex. */
- (void)populate;

#pragma mark - Getters and setters -- frameworks

- (BOOL)hasFrameworkWithName:(NSString *)frameworkName;

#pragma mark - Getters and setters -- classes

- (NSArray<AKClassToken *> *)classesForFramework:(NSString *)frameworkName;
- (AKClassToken *)classWithName:(NSString *)className;

#pragma mark - Getters and setters -- protocols

- (NSArray<AKProtocolToken *> *)formalProtocolsForFramework:(NSString *)frameworkName;
- (NSArray<AKProtocolToken *> *)informalProtocolsForFramework:(NSString *)frameworkName;
- (AKProtocolToken *)protocolWithName:(NSString *)name;

/*! Does nothing if we already contain a protocol with that name. */
- (void)addProtocolToken:(AKProtocolToken *)protocolToken;

#pragma mark - Getters and setters -- functions

- (NSArray *)functionsGroupsForFramework:(NSString *)frameworkName;
- (AKGroupItem *)functionsGroupNamed:(NSString *)groupName inFramework:(NSString *)frameworkName;
- (void)addFunctionsGroup:(AKGroupItem *)functionsGroup;

#pragma mark - Getters and setters -- globals

- (NSArray *)globalsGroupsForFramework:(NSString *)frameworkName;
- (AKGroupItem *)globalsGroupNamed:(NSString *)groupName inFramework:(NSString *)frameworkName;
- (void)addGlobalsGroup:(AKGroupItem *)globalsGroup;

@end
