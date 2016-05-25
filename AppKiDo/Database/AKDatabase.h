/*
 * AKDatabase.h
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "DocSetModel.h"

@class AKClassToken;
@class AKFunctionToken;
@class AKFramework;
@class AKManagedObjectQuery;
@class AKNamedObjectCluster;
@class AKNamedObjectGroup;
@class AKProtocolToken;
@class AKToken;
@class DocSetIndex;

/*!
 * Contains information about a Cocoa-style API: the names of API constructs,
 * the logical relationships between them, and where each one is documented.
 * An example of a fact in this database is "The Foundation class NSString is a
 * subclass of NSObject, and is documented in file XYZ."
 *
 * Before querying a database, you need to populate it by calling -populate,
 * which imports imformation from the database's DocSetIndex.  An AKDatabase
 * lives entirely in memory, and there is currently no way to save the imported
 * information; it must be re-imported when the application relaunches.
 */
@interface AKDatabase : NSObject

@property (readonly, strong) DocSetIndex *docSetIndex;
@property (readonly, copy) NSArray *sortedFrameworkNames;
@property (readonly, copy) NSArray *frameworks;
@property (readonly, copy) NSArray *rootClasses;
@property (readonly, copy) NSArray *allClasses;
@property (readonly, copy) NSArray *allProtocols;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDocSetIndex:(DocSetIndex *)docSetIndex NS_DESIGNATED_INITIALIZER;

#pragma mark - Populating the database

/*! Imports information from the DocSetIndex. */
- (void)populate;

#pragma mark - Frameworks

- (AKFramework *)frameworkWithName:(NSString *)frameworkName;

#pragma mark - Class Tokens

- (NSArray<AKClassToken *> *)classesForFramework:(NSString *)frameworkName;
- (AKClassToken *)classWithName:(NSString *)className;

#pragma mark - Protocol Tokens

- (NSArray<AKProtocolToken *> *)protocolsForFramework:(NSString *)frameworkName;
- (AKProtocolToken *)protocolWithName:(NSString *)name;

@end

