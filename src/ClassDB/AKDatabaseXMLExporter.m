/*
 *  AKDatabaseXMLExporter.m
 *  AppKiDo
 *
 *  Created by Andy Lee on 12/31/07.
 *  Copyright 2007 Andy Lee. All rights reserved.
 */

#import "AKDatabaseXMLExporter.h"

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

//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKDatabaseXMLExporter (Private)

- (void)_openXMLElement:(NSString *)xmlElementName
    nameAttribute:(NSString *)nameAttribute
    typeAttribute:(NSString *)typeAttribute
    deprecated:(BOOL)deprecated
    alsoClose:(BOOL)alsoClose;
- (void)_openXMLElement:(NSString *)xmlElementName
    nameAttribute:(NSString *)nameAttribute
    typeAttribute:(NSString *)typeAttribute;
- (void)_openXMLElement:(NSString *)xmlElementName
    nameAttribute:(NSString *)nameAttribute;
- (void)_openXMLElement:(NSString *)xmlElementName;
- (void)_closeXMLElement:(NSString *)xmlElementName;

@end


@implementation AKDatabaseXMLExporter

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithDatabase:(AKDatabase *)database
{
    if ((self = [super initWithDatabase:database]))
    {
        _indent = 0;
    }
    
    return self;
}

//-------------------------------------------------------------------------
// The main export method
//-------------------------------------------------------------------------

- (void)exportToFileHandle:(NSFileHandle *)fileHandle
{
    _indent = 0;

    [super exportToFileHandle:fileHandle];
}

//-------------------------------------------------------------------------
// Exporting -- top level
//-------------------------------------------------------------------------

- (void)_writeFileBeginning
{
    // Obligatory XML intro.
    [self _writeLine:@"<?xml version=\"1.0\"?>"];
    [self _writeLine];

    // Open a <database> element.
    [self _writeLine:@"<database>"];
    [self _writeLine];
}

- (void)_writeFileEnd
{
    // Close the <database> element.
    [self _writeLine:@"</database>"];
    
}

- (void)_exportFrameworkNamed:(NSString *)fwName
{
    [self
         _writeLine:
            [NSString
                stringWithFormat:@"<!-- ========== [ %@ ] ========== -->",
                [self _spreadString:fwName]]];

    // Open a <framework> element.
    [self _openXMLElement:@"framework" nameAttribute:fwName];

    // Export components of the framework.
    [super _exportFrameworkNamed:fwName];

    // Close the <framework> element.
    [self _closeXMLElement:@"framework"];

    // Spacer line.
    [self _writeLine:@""];
}

//-------------------------------------------------------------------------
// Exporting -- classes and protocols
//-------------------------------------------------------------------------

- (void)_exportClassesForFramework:(NSString *)fwName
{
    [self
        _writeLine:
            [NSString
                stringWithFormat:
                    @"<!-- ===== %@ classes ===== -->",
                    fwName]];

    // Open a <classes> element.
    [self _openXMLElement:@"classes"];

    // Export the class nodes.
    [super _exportClassesForFramework:fwName];

    // Close the <classes> element.
    [self _closeXMLElement:@"classes"];
}

- (void)_exportClass:(AKClassNode *)classNode
{
    [self
        _writeLine:
            [NSString
                stringWithFormat:
                    @"<!-- ===== class %@ ===== -->",
                    [classNode nodeName]]];

    // Open a <class> element.
    [self _openXMLElement:@"class" nameAttribute:[classNode nodeName]];

    // Export the class's methods.
    [super _exportClass:classNode];

    // Close the <class> element.
    [self _closeXMLElement:@"class"];
}

- (void)_exportProtocolsForFramework:(NSString *)fwName
{
    [self
        _writeLine:
            [NSString
                stringWithFormat:
                    @"<!-- ===== %@ protocols ===== -->",
                    fwName]];

    // Open a <protocols> element.
    [self _openXMLElement:@"protocols"];

    // Export the protocols.
    [super _exportProtocolsForFramework:fwName];

    // Close the <protocols> element.
    [self _closeXMLElement:@"protocols"];
}

- (void)_exportProtocolsForFramework:(NSString *)fwName
    formal:(BOOL)formalFlag
{
    _indent--;
    [self
        _writeLine:
            [NSString
                stringWithFormat:
                    @"<!-- ===== %@ %@ protocols ===== -->",
                    fwName,
                    formalFlag ? @"formal" : @"informal"]];
    _indent++;

    [super _exportProtocolsForFramework:fwName formal:formalFlag];
}

- (void)_exportProtocol:(AKProtocolNode *)protocolNode formal:(BOOL)formalFlag
{
    // Dividing line marking the beginning of a protocol.
    [self
        _writeLine:
            [NSString
                stringWithFormat:
                    @"<!-- ===== protocol %@ ===== -->",
                    [protocolNode nodeName]]];

    // Open a <protocol> element.
    [self _openXMLElement:@"protocol"
        nameAttribute:[protocolNode nodeName]
        typeAttribute:(formalFlag ? @"formal" : @"informal")];

    // Export the protocol's methods.
    [super _exportProtocol:protocolNode formal:formalFlag];

    // Close the <protocol> element.
    [self _closeXMLElement:@"protocol"];
}

- (void)_exportClassMethods:(NSArray *)methodNodes
{
    [self _writeLine:@"<!-- ## classmethods ## -->"];

    // Open a <classmethods> element.
    [self _openXMLElement:@"classmethods"];

    // Export the methods.
    [super _exportClassMethods:methodNodes];

    // Close the <classmethods> element.
    [self _closeXMLElement:@"classmethods"];
}

- (void)_exportInstanceMethods:(NSArray *)methodNodes
{
    [self _writeLine:@"<!-- ## instancemethods ## -->"];

    // Open an <instancemethods> element.
    [self _openXMLElement:@"instancemethods"];

    // Export the methods.
    [super _exportInstanceMethods:methodNodes];

    // Close the <instancemethods> element.
    [self _closeXMLElement:@"instancemethods"];
}

- (void)_exportDelegateMethods:(NSArray *)methodNodes
{
    [self _writeLine:@"<!-- ## delegatemethods ## -->"];

    // Open a <delegatemethods> element.
    [self _openXMLElement:@"delegatemethods"];

    // Export the methods.
    [super _exportDelegateMethods:methodNodes];

    // Close the <delegatemethods> element.
    [self _closeXMLElement:@"delegatemethods"];
}

- (void)_exportNotifications:(NSArray *)methodNodes
{
    [self _writeLine:@"<!-- ## notifications ## -->"];

    // Open a <notifications> element.
    [self _openXMLElement:@"notifications"];

    // Export the methods.
    [super _exportNotifications:methodNodes];

    // Close the <notifications> element.
    [self _closeXMLElement:@"notifications"];
}

- (void)_exportMethod:(AKMethodNode *)methodNode
{
    // Create a <method/> element.
    [self
        _openXMLElement:@"method"
        nameAttribute:[methodNode nodeName]
        typeAttribute:nil
        deprecated:[methodNode isDeprecated]
        alsoClose:YES];
}

//-------------------------------------------------------------------------
// Exporting -- functions and globals
//-------------------------------------------------------------------------

- (void)_exportFunctionsForFramework:(NSString *)fwName
{
    [self
        _writeLine:
            [NSString
                stringWithFormat:
                    @"<!-- ===== %@ functions ===== -->",
                    fwName]];

    // Open a <functions> element.
    [self _openXMLElement:@"functions"];

    // Export the function groups.
    [super _exportFunctionsForFramework:fwName];

    // Close the <functions> element.
    [self _closeXMLElement:@"functions"];
}

- (void)_exportFunctionsGroupNode:(AKGroupNode *)groupNode
{
    NSString *s =
        [NSString
            stringWithFormat:
                @"<!-- ===== [%@] ===== -->",
                [groupNode nodeName]];
    [self _writeLine:s];

    // Open a <group> element.
    [self _openXMLElement:@"group" nameAttribute:[groupNode nodeName]];

    // Iterate through subnodes of the group.
    [super _exportFunctionsGroupNode:groupNode];

    // Close the <group> element.
    [self _closeXMLElement:@"group"];
}

- (void)_exportFunction:(AKFunctionNode *)functionNode
{
    [self
        _openXMLElement:@"function"
        nameAttribute:[functionNode nodeName]
        typeAttribute:nil
        deprecated:[functionNode isDeprecated]
        alsoClose:YES];
}

- (void)_exportGlobalsForFramework:(NSString *)fwName
{
    [self
        _writeLine:
            [NSString
            stringWithFormat:
                @"<!-- ===== %@ types and constants ===== -->",
                fwName]];

    // Open a <globals> element.
    [self _openXMLElement:@"globals"];

    // Export the groups of types and constants.
    [super _exportGlobalsForFramework:fwName];

    // Close the <globals> element.
    [self _closeXMLElement:@"globals"];
}

- (void)_exportGlobalsGroupNode:(AKGroupNode *)groupNode
{
    NSString *s =
        [NSString
            stringWithFormat:
                @"<!-- ===== [%@] ===== -->",
                [groupNode nodeName]];
    [self _writeLine:s];

    // Open a <group> element.
    [self _openXMLElement:@"group" nameAttribute:[groupNode nodeName]];

    // Iterate through subnodes of the group.
    [super _exportGlobalsGroupNode:groupNode];

    // Close the <group> element.
    [self _closeXMLElement:@"group"];
}

- (void)_exportGlobal:(AKDatabaseNode *)databaseNode
{
    [self
        _openXMLElement:@"global"
        nameAttribute:[databaseNode nodeName]
        typeAttribute:nil
        deprecated:[databaseNode isDeprecated]
        alsoClose:YES];
}

//-------------------------------------------------------------------------
// Low-level utility methods
//-------------------------------------------------------------------------

- (void)_writeLine:(NSString *)s
{
    int i;

    for (i = 0; i < _indent; i++)
    {
        s = [@"    " stringByAppendingString:s];
    }

    [super _writeLine:s];
}

@end


@implementation AKDatabaseXMLExporter (Private)

- (void)_openXMLElement:(NSString *)xmlElementName
    nameAttribute:(NSString *)nameAttribute
    typeAttribute:(NSString *)typeAttribute
    deprecated:(BOOL)deprecated
    alsoClose:(BOOL)alsoClose
{
    NSString *maybeNameAttribute =
        nameAttribute
        ? [NSString stringWithFormat:@" name=\"%@\"", nameAttribute]
        : @"";
    NSString *maybeTypeAttribute =
        typeAttribute
        ? [NSString stringWithFormat:@" type=\"%@\"", typeAttribute]
        : @"";
    NSString *maybeDeprecated = deprecated ? @" deprecated=\"true\"" : @"";
    NSString *maybeClose = alsoClose ? @"/" : @"";

    [self
        _writeLine:
            [NSString
                stringWithFormat:
                    @"<%@%@%@%@%@>",
                    xmlElementName,
                    maybeNameAttribute,
                    maybeTypeAttribute,
                    maybeDeprecated,
                    maybeClose]];
    if (!alsoClose)
    {
        _indent++;
    }
}

- (void)_openXMLElement:(NSString *)xmlElementName
    nameAttribute:(NSString *)nameAttribute
    typeAttribute:(NSString *)typeAttribute
{
    [self
        _openXMLElement:xmlElementName
        nameAttribute:nameAttribute
        typeAttribute:typeAttribute
        deprecated:NO
        alsoClose:NO];
}

- (void)_openXMLElement:(NSString *)xmlElementName
    nameAttribute:(NSString *)nameAttribute
{
    [self
        _openXMLElement:xmlElementName
        nameAttribute:nameAttribute
        typeAttribute:nil
        deprecated:NO
        alsoClose:NO];
}

- (void)_openXMLElement:(NSString *)xmlElementName
{
    [self
        _openXMLElement:xmlElementName
        nameAttribute:nil
        typeAttribute:nil
        deprecated:NO
        alsoClose:NO];
}

- (void)_closeXMLElement:(NSString *)xmlElementName
{
    _indent--;
    [self _writeLine:[NSString stringWithFormat:@"</%@>", xmlElementName]];
}

@end
