/*
 *  AKDatabaseExporter.h
 *  AppKiDo
 *
 *  Created by Andy Lee on 05/04/08.
 *  Copyright 2008 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

@class AKDatabase;
@class AKDatabaseNode;
@class AKClassNode;
@class AKProtocolNode;
@class AKMethodNode;
@class AKGroupNode;
@class AKFunctionNode;

/*!
 * class        AKDatabaseExporter
 * @discussion  Support for exporting an AKDatabase to an XML file.
 */
@interface AKDatabaseExporter : NSObject
{
@private
    AKDatabase *_database;

@protected
    NSFileHandle *_fileHandle;  // only used during export
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)exporterWithDefaultDatabase;

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*! Designated initialzer. */
- (id)initWithDatabase:(AKDatabase *)database;

//-------------------------------------------------------------------------
// The main export method
//-------------------------------------------------------------------------

/*!
 * @method      exportToFileHandle:
 * @discussion  Exports the database's nodes and frameworks in XML
 *              format.
 *
 *              The exported information is useful for debugging and
 *              regression testing.  It could also be used to see what
 *              API changes have occurred in a new OS release.  It is
 *              not quite sufficient to reconstruct a database from
 *              scratch.
 */
- (void)exportToFileHandle:(NSFileHandle *)fh;

//-------------------------------------------------------------------------
// Exporting -- top level
//-------------------------------------------------------------------------

- (void)_writeFileBeginning;
- (void)_writeFileEnd;

/*! Called for each framework. */
- (void)_exportFrameworkNamed:(NSString *)fwName;

//-------------------------------------------------------------------------
// Exporting -- classes
//-------------------------------------------------------------------------

/*! Repeatedly calls _exportClass:. */
- (void)_exportClassesForFramework:(NSString *)fwName;
- (void)_exportClass:(AKClassNode *)classNode;

//-------------------------------------------------------------------------
// Exporting -- protocols
//-------------------------------------------------------------------------

- (void)_exportProtocolsForFramework:(NSString *)fwName;
- (void)_exportProtocolsForFramework:(NSString *)fwName
    formal:(BOOL)formalFlag;
- (void)_exportProtocol:(AKProtocolNode *)protocolNode formal:(BOOL)formalFlag;

//-------------------------------------------------------------------------
// Exporting -- methods
//-------------------------------------------------------------------------

- (void)_exportClassMethods:(NSArray *)methodNodes;
- (void)_exportInstanceMethods:(NSArray *)methodNodes;
- (void)_exportDelegateMethods:(NSArray *)methodNodes;
- (void)_exportNotifications:(NSArray *)methodNodes;

- (void)_exportMethod:(AKMethodNode *)methodNode;

//-------------------------------------------------------------------------
// Exporting -- functions and globals
//-------------------------------------------------------------------------

- (void)_exportFunctionsForFramework:(NSString *)fwName;
- (void)_exportFunctionsGroupNode:(AKGroupNode *)groupNode;
- (void)_exportFunction:(AKFunctionNode *)groupNode;

- (void)_exportGlobalsForFramework:(NSString *)fwName;
- (void)_exportGlobalsGroupNode:(AKGroupNode *)groupNode;
- (void)_exportGlobal:(AKDatabaseNode *)databaseNode;

//-------------------------------------------------------------------------
// Low-level utility methods
//-------------------------------------------------------------------------

- (void)_writeLine:(NSString *)s;
- (void)_writeLine;

- (NSString *)_spreadString:(NSString *)s;

@end
