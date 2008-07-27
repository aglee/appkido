/*
 *  AKDatabaseExporter.m
 *  AppKiDo
 *
 *  Created by Andy Lee on 05/04/08.
 *  Copyright 2008 Andy Lee. All rights reserved.
 */

#import "AKDatabaseExporter.h"

#import "DIGSLog.h"

#import "AKDatabase.h"

#import "AKSortUtils.h"

#import "AKFileSection.h"
#import "AKClassNode.h"
#import "AKProtocolNode.h"
#import "AKCategoryNode.h"
#import "AKMethodNode.h"
#import "AKGroupNode.h"
#import "AKGlobalsNode.h"


@interface AKDatabaseExporter (Private)
- (void)_exportMethods:(NSArray *)methodNodes;
@end


@implementation AKDatabaseExporter

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)exporterWithDefaultDatabase
{
    return
        [[[self alloc]
            initWithDatabase:[AKDatabase defaultDatabase]] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithDatabase:(AKDatabase *)database
{
    if ((self = [super init]))
    {
        _database = [database retain];
        _fileHandle = nil;
    }
    
    return self;
}

- (id)init
{
    DIGSLogNondesignatedInitializer();
    [self dealloc];
    return nil;
}

- (void)dealloc
{
    [_database release];
    [_fileHandle release];
    
    [super dealloc];
}

//-------------------------------------------------------------------------
// The main export method
//-------------------------------------------------------------------------

- (void)exportToFileHandle:(NSFileHandle *)fileHandle
{
    _fileHandle = [fileHandle retain];

    // Write stuff at beginning of file.
    [self _writeFileBeginning];

    // Iterate through all frameworks in the database, in order of
    // framework name.
    NSEnumerator *fwNamesEnum =
        [[[_database sortedFrameworkNames]
            sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]
            objectEnumerator];
    NSString *fwName;

    while ((fwName = [fwNamesEnum nextObject]))
    {
        [self _exportFrameworkNamed:fwName];
    }

    // Write stuff at end of file.
    [self _writeFileEnd];

    // Clean up.
    [_fileHandle release];
    _fileHandle = nil;
}

//-------------------------------------------------------------------------
// Exporting -- top level
//-------------------------------------------------------------------------

- (void)_writeFileBeginning
{
    // By default do nothing.
}

- (void)_writeFileEnd
{
    // By default do nothing.
}

- (void)_exportFrameworkNamed:(NSString *)fwName
{
    // Export classes and protocols.
    [self _exportClassesForFramework:fwName];
    [self _exportProtocolsForFramework:fwName];

    // Export functions and globals.
    [self _exportFunctionsForFramework:fwName];
    [self _exportGlobalsForFramework:fwName];
}

//-------------------------------------------------------------------------
// Exporting -- classes
//-------------------------------------------------------------------------

- (void)_exportClassesForFramework:(NSString *)fwName
{
    // Iterate through the class nodes.
    NSArray *classNodes =
        [AKSortUtils arrayBySortingArray:[_database classesForFramework:fwName]];
    NSEnumerator *classEnum = [classNodes objectEnumerator];
    AKClassNode *classNode;

    while ((classNode = [classEnum nextObject]))
    {
        if ([[classNode owningFramework] isEqualToString:fwName])
        {
            [self _exportClass:classNode];
        }
    }
}

- (void)_exportClass:(AKClassNode *)classNode
{
    // Class methods.
    [self _exportClassMethods:[classNode documentedClassMethods]];

    // Instance methods.
    [self _exportInstanceMethods:[classNode documentedInstanceMethods]];

    // Delegate methods.
    [self _exportDelegateMethods:[classNode documentedDelegateMethods]];

    // Notifications.
    [self _exportNotifications:[classNode documentedNotifications]];
}

//-------------------------------------------------------------------------
// Exporting -- protocols
//-------------------------------------------------------------------------

- (void)_exportProtocolsForFramework:(NSString *)fwName
{
    // Formal protocols.
    [self _exportProtocolsForFramework:fwName formal:YES];

    // Informal protocols.
    [self _exportProtocolsForFramework:fwName formal:NO];
}

- (void)_exportProtocolsForFramework:(NSString *)fwName
    formal:(BOOL)formalFlag
{
    NSArray *protocolNodes =
        formalFlag
        ? [_database formalProtocolsForFramework:fwName]
        : [_database informalProtocolsForFramework:fwName];
    NSEnumerator *protocolNodeEnum =
        [[AKSortUtils arrayBySortingArray:protocolNodes] objectEnumerator];
    AKProtocolNode *protocolNode;

    while ((protocolNode = [protocolNodeEnum nextObject]))
    {
        [self _exportProtocol:protocolNode formal:formalFlag];
    }
}

- (void)_exportProtocol:(AKProtocolNode *)protocolNode formal:(BOOL)formalFlag
{
    // Class methods.
    [self _exportClassMethods:[protocolNode documentedClassMethods]];

    // Instance methods.
    [self _exportInstanceMethods:[protocolNode documentedInstanceMethods]];
}

//-------------------------------------------------------------------------
// Exporting -- methods
//-------------------------------------------------------------------------

- (void)_exportClassMethods:(NSArray *)methodNodes
{
    [self _exportMethods:methodNodes];
}

- (void)_exportInstanceMethods:(NSArray *)methodNodes
{
    [self _exportMethods:methodNodes];
}

- (void)_exportDelegateMethods:(NSArray *)methodNodes
{
    [self _exportMethods:methodNodes];
}

- (void)_exportNotifications:(NSArray *)methodNodes
{
    [self _exportMethods:methodNodes];
}

- (void)_exportMethod:(AKMethodNode *)methodNode
{
}

//-------------------------------------------------------------------------
// Exporting -- functions and globals
//-------------------------------------------------------------------------

- (void)_exportFunctionsForFramework:(NSString *)fwName
{
    // Iterate through all the groups of functions.
    NSArray *groupNodes =
        [AKSortUtils
            arrayBySortingArray:[_database functionsGroupsForFramework:fwName]];
    NSEnumerator *groupEnum = [groupNodes objectEnumerator];
    AKGroupNode *groupNode;

    while ((groupNode = [groupEnum nextObject]))
    {
        [self _exportFunctionsGroupNode:groupNode];
    }
}

- (void)_exportFunctionsGroupNode:(AKGroupNode *)groupNode
{
    // Iterate through subnodes of the group.
    NSEnumerator *subnodeEnum =
        [[AKSortUtils arrayBySortingArray:[groupNode subnodes]]
            objectEnumerator];
    AKFunctionNode *subnode;

    while ((subnode = [subnodeEnum nextObject]))
    {
        [self _exportFunction:subnode];
    }
}

- (void)_exportFunction:(AKFunctionNode *)groupNode
{
}

- (void)_exportGlobalsForFramework:(NSString *)fwName
{
    // Iterate through all the groups of types and constants.
    NSArray *groupNodes =
        [AKSortUtils
            arrayBySortingArray:[_database globalsGroupsForFramework:fwName]];
    NSEnumerator *groupEnum = [groupNodes objectEnumerator];
    AKGroupNode *groupNode;

    while ((groupNode = [groupEnum nextObject]))
    {
        [self _exportGlobalsGroupNode:groupNode];
    }
}

- (void)_exportGlobalsGroupNode:(AKGroupNode *)groupNode
{
    // Iterate through subnodes of the group.
    NSEnumerator *subnodeEnum =
        [[AKSortUtils arrayBySortingArray:[groupNode subnodes]]
            objectEnumerator];
    AKDatabaseNode *subnode;

    while ((subnode = [subnodeEnum nextObject]))
    {
        [self _exportGlobal:subnode];
    }
}

- (void)_exportGlobal:(AKDatabaseNode *)databaseNode
{
}

//-------------------------------------------------------------------------
// Low-level utility methods
//-------------------------------------------------------------------------

- (void)_writeLine:(NSString *)s
{
    s = [s stringByAppendingString:@"\n"];

    [_fileHandle writeData:[s dataUsingEncoding:NSASCIIStringEncoding]];
}

- (void)_writeLine
{
    [_fileHandle writeData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding]];
}

- (NSString *)_spreadString:(NSString *)s
{
    NSMutableString *result = [NSMutableString string];
    int numChars = [s length];
    int i;

    for (i = 0; i < numChars; i++)
    {
        if (i > 0)
        {
            [result appendString:@" "];
        }

        NSRange range = NSMakeRange(i, 1);

        [result appendString:[s substringWithRange:range]];
    }

    return result;
}

@end



@implementation AKDatabaseExporter (Private)

- (void)_exportMethods:(NSArray *)methodNodes
{
    // Iterate through the given list of methods.
    NSEnumerator *methodEnum =
        [[AKSortUtils arrayBySortingArray:methodNodes] objectEnumerator];
    AKMethodNode *methodNode;

    while ((methodNode = [methodEnum nextObject]))
    {
        [self _exportMethod:methodNode];
    }
}

@end


