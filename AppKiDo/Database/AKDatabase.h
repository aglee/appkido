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
@class AKInstalledSDK;
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
 * which imports information from the database's DocSetIndex and from header
 * files in the referenceSDK directory.
 *
 * An AKDatabase lives entirely in memory.  There is currently no support for
 * saving the imported information; it must be re-imported when the application
 * relaunches.
 */
@interface AKDatabase : NSObject

@property (readonly, strong) DocSetIndex *docSetIndex;
@property (readonly) AKInstalledSDK *referenceSDK;
@property (readonly, copy) NSArray *sortedFrameworkNames;
@property (readonly, copy) NSArray *frameworks;
@property (readonly, copy) NSArray *rootClassTokens;
@property (readonly, copy) NSArray *allClassTokens;
@property (readonly, copy) NSArray *allProtocolTokens;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithDocSetIndex:(DocSetIndex *)docSetIndex
								SDK:(AKInstalledSDK *)installedSDK NS_DESIGNATED_INITIALIZER;

#pragma mark - Populating the database

/*! Imports information from the DocSetIndex. */
- (void)populate;

#pragma mark - Frameworks

- (AKFramework *)frameworkWithName:(NSString *)frameworkName;

#pragma mark - Class Tokens

- (NSArray<AKClassToken *> *)classTokensInFramework:(NSString *)frameworkName;
- (AKClassToken *)classTokenWithName:(NSString *)className;

#pragma mark - Protocol Tokens

- (NSArray<AKProtocolToken *> *)protocolTokensInFramework:(NSString *)frameworkName;
- (AKProtocolToken *)protocolTokenWithName:(NSString *)name;

@end

