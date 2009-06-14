/*
 *  AKDatabaseXMLExporter.m
 *  AppKiDo
 *
 *  Created by Andy Lee on 12/31/07.
 *  Copyright 2007 Andy Lee. All rights reserved.
 */

#import "AKDatabaseXMLExporter.h"

#import "DIGSLog.h"

#import "AKSortUtils.h"

#import "AKDatabase.h"
#import "AKMemberNode.h"
#import "AKClassNode.h"
#import "AKProtocolNode.h"
#import "AKGroupNode.h"

//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKDatabaseXMLExporter (Private)

- (void)_performSelector:(SEL)aSelector onStrings:(NSArray *)strings;
- (void)_performSelector:(SEL)aSelector onNodes:(NSArray *)nodes;
- (void)_performSelector:(SEL)aSelector
    onNodes:(NSArray *)nodes
    with:(id)arg;

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

- (NSString *)_spreadString:(NSString *)s;

- (void)_writeLine:(NSString *)s;
- (void)_writeLine;

- (void)_writeLongDividerWithString:(NSString *)aString;
- (void)_writeDividerWithString:(NSString *)aString;
- (void)_writeAltDividerWithString:(NSString *)aString;
- (void)_writeDividerWithString:(NSString *)string1
    string:(NSString *)string2;
- (void)_writeShortDividerWithString:(NSString *)aString;

@end


@implementation AKDatabaseXMLExporter

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithDatabase:(AKDatabase *)database
    fileHandle:(NSFileHandle *)outfile
{
    if ((self = [super init]))
    {
        _database = [database retain];
        _outfile = [outfile retain];
    }
    
    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    [self release];
    return nil;
}

- (void)dealloc
{
    [_database release];
    [_outfile release];
    
    [super dealloc];
}

//-------------------------------------------------------------------------
// The main export method
//-------------------------------------------------------------------------

- (void)doExport
{
    _indent = 0;

    [self _writeLine:@"<?xml version=\"1.0\"?>"];
    [self _writeLine];
    [self _writeLine:@"<database>"];
    [self _writeLine];

        [self
            _performSelector:@selector(exportFrameworkNamed:)
            onStrings:[_database frameworkNames]];

    [self _writeLine:@"</database>"];
}

//-------------------------------------------------------------------------
// Exporting -- members
//-------------------------------------------------------------------------

- (void)exportMembers:(NSString *)membersType
    ofBehavior:(AKBehaviorNode *)behaviorNode
    usingGetSelector:(SEL)getSelector
    xmlTag:(NSString *)memberTag
{
    [self _writeShortDividerWithString:membersType];
    [self _openXMLElement:membersType];

        [self
            _performSelector:@selector(exportMember:withXMLTag:)
            onNodes:[behaviorNode performSelector:getSelector]
            with:memberTag];

    [self _closeXMLElement:membersType];
}

- (void)exportMember:(AKMemberNode *)memberNode
    withXMLTag:(NSString *)memberTag
{
    [self
        _openXMLElement:memberTag
        nameAttribute:[memberNode nodeName]
        typeAttribute:nil
        deprecated:[memberNode isDeprecated]
        alsoClose:YES];
}

//-------------------------------------------------------------------------
// Exporting -- classes and protocols
//-------------------------------------------------------------------------

- (void)exportClass:(AKClassNode *)classNode
{
    [self _writeDividerWithString:@"class" string:[classNode nodeName]];
    [self _openXMLElement:@"class" nameAttribute:[classNode nodeName]];

        [self
            exportMembers:@"properties"
            ofBehavior:classNode
            usingGetSelector:@selector(documentedProperties)
            xmlTag:@"property"];
        [self
            exportMembers:@"classmethods"
            ofBehavior:classNode
            usingGetSelector:@selector(documentedClassMethods)
            xmlTag:@"method"];
        [self
            exportMembers:@"instancemethods"
            ofBehavior:classNode
            usingGetSelector:@selector(documentedInstanceMethods)
            xmlTag:@"method"];
        [self
            exportMembers:@"delegatemethods"
            ofBehavior:classNode
            usingGetSelector:@selector(documentedDelegateMethods)
            xmlTag:@"method"];
        [self
            exportMembers:@"notifications"
            ofBehavior:classNode
            usingGetSelector:@selector(documentedNotifications)
            xmlTag:@"notification"];

    [self _closeXMLElement:@"class"];
}

- (void)exportProtocol:(AKProtocolNode *)protocolNode
{
    [self _writeDividerWithString:@"protocol" string:[protocolNode nodeName]];
    [self _openXMLElement:@"protocol"
        nameAttribute:[protocolNode nodeName]
        typeAttribute:([protocolNode isInformal] ? @"informal" : @"formal")];

        [self
            exportMembers:@"properties"
            ofBehavior:protocolNode
            usingGetSelector:@selector(documentedProperties)
            xmlTag:@"property"];
        [self
            exportMembers:@"classmethods"
            ofBehavior:protocolNode
            usingGetSelector:@selector(documentedClassMethods)
            xmlTag:@"method"];
        [self
            exportMembers:@"instancemethods"
            ofBehavior:protocolNode
            usingGetSelector:@selector(documentedInstanceMethods)
            xmlTag:@"method"];

    [self _closeXMLElement:@"protocol"];
}

//-------------------------------------------------------------------------
// Exporting -- group nodes
//-------------------------------------------------------------------------

- (void)exportGroupSubnode:(AKDatabaseNode *)databaseNode
    withXMLTag:(NSString *)subnodeTag
{
    [self
        _openXMLElement:subnodeTag
        nameAttribute:[databaseNode nodeName]
        typeAttribute:nil
        deprecated:[databaseNode isDeprecated]
        alsoClose:YES];
}

- (void)exportGroupNode:(AKGroupNode *)groupNode
    usingSubnodeTag:(NSString *)subnodeTag
{
    [self _writeAltDividerWithString:[groupNode nodeName]];
    [self _openXMLElement:@"group" nameAttribute:[groupNode nodeName]];

        [self
            _performSelector:@selector(exportGroupSubnode:withXMLTag:)
            onNodes:[groupNode subnodes]
            with:subnodeTag];

    [self _closeXMLElement:@"group"];
}

//-------------------------------------------------------------------------
// Exporting -- frameworks
//-------------------------------------------------------------------------

- (void)exportNodesInSection:(NSString *)frameworkSection
    ofFramework:(NSString *)fwName
    usingGetSelector:(SEL)getSelector
    exportSelector:(SEL)exportSelector
{
    [self _writeDividerWithString:fwName string:frameworkSection];
    [self _openXMLElement:frameworkSection];

        [self
            _performSelector:exportSelector
            onNodes:[_database performSelector:getSelector withObject:fwName]];

    [self _closeXMLElement:frameworkSection];
}

- (void)exportProtocolsForFramework:(NSString *)fwName
{
    [self _writeDividerWithString:fwName string:@"protocols"];
    [self _openXMLElement:@"protocols"];

        // Write formal protocols.
        _indent--;
        [self _writeDividerWithString:fwName string:@"formal protocols"];
        _indent++;
        [self
            _performSelector:@selector(exportProtocol:)
            onNodes:[_database formalProtocolsForFramework:fwName]];

        // Write informal protocols.
        _indent--;
        [self _writeDividerWithString:fwName string:@"informal protocols"];
        _indent++;
        [self
            _performSelector:@selector(exportProtocol:)
            onNodes:[_database informalProtocolsForFramework:fwName]];

    [self _closeXMLElement:@"protocols"];
}

- (void)exportGroupNodesInSection:(NSString *)frameworkSection
    ofFramework:(NSString *)fwName
    usingGetSelector:(SEL)getSelector
    subnodeTag:(NSString *)subnodeTag
{
    [self _writeDividerWithString:fwName string:frameworkSection];
    [self _openXMLElement:frameworkSection];

        [self
            _performSelector:@selector(exportGroupNode:usingSubnodeTag:)
            onNodes:[_database performSelector:getSelector withObject:fwName]
            with:subnodeTag];

    [self _closeXMLElement:frameworkSection];
}

- (void)exportFrameworkNamed:(NSString *)fwName
{
    [self _writeLongDividerWithString:fwName];
    [self _openXMLElement:@"framework" nameAttribute:fwName];

        [self
            exportNodesInSection:@"classes"
            ofFramework:fwName
            usingGetSelector:@selector(classesForFramework:)
            exportSelector:@selector(exportClass:)];
        [self exportProtocolsForFramework:fwName];
        [self
            exportGroupNodesInSection:@"functions"
            ofFramework:fwName
            usingGetSelector:@selector(functionsGroupsForFramework:)
            subnodeTag:@"function"];
        [self
            exportGroupNodesInSection:@"globals"
            ofFramework:fwName
            usingGetSelector:@selector(globalsGroupsForFramework:)
            subnodeTag:@"global"];

    [self _closeXMLElement:@"framework"];
    [self _writeLine:@""];
}

//-------------------------------------------------------------------------
// Low-level utility methods
//-------------------------------------------------------------------------

@end


@implementation AKDatabaseXMLExporter (Private)

- (void)_performSelector:(SEL)aSelector onStrings:(NSArray *)strings
{
    NSEnumerator *arrayEnum =
        [[strings sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]
            objectEnumerator];
    NSObject *element;

    while ((element = [arrayEnum nextObject]))
    {
        [self performSelector:aSelector withObject:element];
    }
}

- (void)_performSelector:(SEL)aSelector onNodes:(NSArray *)nodes
{
    NSEnumerator *arrayEnum =
        [[AKSortUtils arrayBySortingArray:nodes] objectEnumerator];
    NSObject *element;

    while ((element = [arrayEnum nextObject]))
    {
        [self performSelector:aSelector withObject:element];
    }
}

- (void)_performSelector:(SEL)aSelector
    onNodes:(NSArray *)nodes
    with:(id)arg
{
    NSEnumerator *arrayEnum =
        [[AKSortUtils arrayBySortingArray:nodes] objectEnumerator];
    NSObject *element;

    while ((element = [arrayEnum nextObject]))
    {
        [self performSelector:aSelector withObject:element withObject:arg];
    }
}

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

- (void)_writeLine:(NSString *)s
{
    int i;

    for (i = 0; i < _indent; i++)
    {
        s = [@"    " stringByAppendingString:s];
    }

    s = [s stringByAppendingString:@"\n"];

    [_outfile writeData:[s dataUsingEncoding:NSASCIIStringEncoding]];
}

- (void)_writeLine
{
    [_outfile writeData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding]];
}

- (void)_writeLongDividerWithString:(NSString *)aString
{
    [self
         _writeLine:
            [NSString
                stringWithFormat:@"<!-- ========== [ %@ ] ========== -->",
                [self _spreadString:aString]]];
}

- (void)_writeDividerWithString:(NSString *)aString
{
    [self
        _writeLine:
            [NSString
                stringWithFormat:
                    @"<!-- ===== %@ ===== -->",
                    aString]];
}

- (void)_writeAltDividerWithString:(NSString *)aString
{
    [self
        _writeLine:
            [NSString
                stringWithFormat:
                    @"<!-- ===== [%@] ===== -->",
                    aString]];
}

- (void)_writeDividerWithString:(NSString *)string1
    string:(NSString *)string2
{
    [self
        _writeLine:
            [NSString
                stringWithFormat:
                    @"<!-- ===== %@ %@ ===== -->",
                    string1, string2]];
}

- (void)_writeShortDividerWithString:(NSString *)aString
{
    [self _writeLine:[NSString stringWithFormat:@"<!-- ## %@ ## -->", aString]];
}

@end
