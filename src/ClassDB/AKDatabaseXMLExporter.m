/*
 *  AKDatabaseXMLExporter.m
 *  AppKiDo
 *
 *  Created by Andy Lee on 12/31/07.
 *  Copyright 2007 Andy Lee. All rights reserved.
 */

#import "AKDatabaseXMLExporter.h"

#import "DIGSLog.h"

#import "AKClassNode.h"
#import "AKDatabase.h"
#import "AKGroupNode.h"
#import "AKMemberNode.h"
#import "AKProtocolNode.h"
#import "AKSortUtils.h"

@implementation AKDatabaseXMLExporter

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithDatabase:(AKDatabase *)database fileURL:(NSURL *)outfileURL;
{
    if ((self = [super init]))
    {
        _database = database;
        _xmlWriter = [[TCMXMLWriter alloc] initWithOptions:(TCMXMLWriterOptionOrderedAttributes
                                                            | TCMXMLWriterOptionPrettyPrinted)
                                                   fileURL:outfileURL];
    }
    
    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}


#pragma mark -
#pragma mark The main export method

- (void)doExport
{
    [_xmlWriter instructXMLStandalone];
    [_xmlWriter tag:@"database" attributes:nil contentBlock:^{
        for (NSString *frameworkName in [_database sortedFrameworkNames])
        {
            [self _exportFrameworkNamed:frameworkName];
        }
    }];
}

#pragma mark -
#pragma mark Private methods -- exporting frameworks

- (void)_exportFrameworkNamed:(NSString *)fwName
{
    [self _writeLongDividerWithString:fwName];
    [_xmlWriter tag:@"framework" attributes:@{ @"name": fwName } contentBlock:^{
        // Export classes.
        [_xmlWriter tag:@"classes" attributes:nil contentBlock:^{
            NSArray *allClassNodes = [_database classesForFrameworkNamed:fwName];
            for (AKClassNode *classNode in [AKSortUtils arrayBySortingArray:allClassNodes])
            {
                [self _exportClass:classNode];
            }
        }];

        // Export protocols.
        [self _exportProtocolsForFramework:fwName];

        // Export functions.
        [self _exportGroupNodes:[_database functionsGroupsForFrameworkNamed:fwName]
                      inSection:@"functions"
                    ofFramework:fwName
                     subnodeTag:@"function"];

        // Export globals.
        [self _exportGroupNodes:[_database globalsGroupsForFrameworkNamed:fwName]
                      inSection:@"globals"
                    ofFramework:fwName
                     subnodeTag:@"global"];
    }];
}

- (void)_exportProtocolsForFramework:(NSString *)fwName
{
    [_xmlWriter tag:@"protocols" attributes:nil contentBlock:^{
        // Write formal protocols.
        [self _writeDividerWithString:fwName string:@"formal protocols"];

        NSArray *formalProtocols = [_database formalProtocolsForFrameworkNamed:fwName];
        for (AKProtocolNode *protocolNode in [AKSortUtils arrayBySortingArray:formalProtocols])
        {
            [self _exportProtocol:protocolNode];
        }

        // Write informal protocols.
        [self _writeDividerWithString:fwName string:@"informal protocols"];

        NSArray *informalProtocols = [_database informalProtocolsForFrameworkNamed:fwName];
        for (AKProtocolNode *protocolNode in [AKSortUtils arrayBySortingArray:informalProtocols])
        {
            [self _exportProtocol:protocolNode];
        }
    }];
}

- (void)_exportGroupNodes:(NSArray *)groupNodes
                inSection:(NSString *)frameworkSection
              ofFramework:(NSString *)fwName
               subnodeTag:(NSString *)subnodeTag
{
    [self _writeDividerWithString:fwName string:frameworkSection];
    [_xmlWriter tag:frameworkSection attributes:nil contentBlock:^{
        for (AKGroupNode *groupNode in [AKSortUtils arrayBySortingArray:groupNodes])
        {
            [self _exportGroupNode:groupNode usingSubnodeTag:subnodeTag];
        }
    }];
}


#pragma mark -
#pragma mark Private methods -- exporting classes and protocols

- (void)_exportClass:(AKClassNode *)classNode
{
    [_xmlWriter tag:@"class" attributes:@{ @"name": classNode.nodeName } contentBlock:^{
        [self _exportMembers:[classNode documentedProperties]
                      ofType:@"properties"
                      xmlTag:@"property"];

        [self _exportMembers:[classNode documentedClassMethods]
                      ofType:@"classmethods"
                      xmlTag:@"method"];

        [self _exportMembers:[classNode documentedInstanceMethods]
                      ofType:@"instancemethods"
                      xmlTag:@"method"];

        [self _exportMembers:[classNode documentedDelegateMethods]
                      ofType:@"delegatemethods"
                      xmlTag:@"method"];

        [self _exportMembers:[classNode documentedNotifications]
                      ofType:@"notifications"
                      xmlTag:@"notification"];
    }];
}

- (void)_exportProtocol:(AKProtocolNode *)protocolNode
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];

    attributes[@"name"] = protocolNode.nodeName;
    attributes[@"type"] = (protocolNode.isInformal ? @"informal" : @"formal");

    [_xmlWriter tag:@"protocol" attributes:attributes contentBlock:^{
        [self _exportMembers:[protocolNode documentedProperties]
                      ofType:@"properties"
                      xmlTag:@"property"];

        [self _exportMembers:[protocolNode documentedClassMethods]
                      ofType:@"classmethods"
                      xmlTag:@"method"];

        [self _exportMembers:[protocolNode documentedInstanceMethods]
                      ofType:@"instancemethods"
                      xmlTag:@"method"];
    }];
}


#pragma mark -
#pragma mark Private methods -- exporting members

- (void)_exportMembers:(NSArray *)memberNodes
                ofType:(NSString *)membersType
                xmlTag:(NSString *)memberTag
{
    [_xmlWriter tag:membersType attributes:nil contentBlock:^{
        for (AKMemberNode *memberNode in [AKSortUtils arrayBySortingArray:memberNodes])
        {
            [self _exportMember:memberNode withXMLTag:memberTag];
        }
    }];
}

- (void)_exportMember:(AKMemberNode *)memberNode withXMLTag:(NSString *)memberTag
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];

    attributes[@"name"] = memberNode.nodeName;

    if (memberNode.isDeprecated)
    {
        attributes[@"isDeprecated"] = @YES;
    }

    [_xmlWriter tag:memberTag attributes:attributes];
}


#pragma mark -
#pragma mark Private methods -- exporting group nodes

- (void)_exportGroupSubnode:(AKDatabaseNode *)databaseNode withXMLTag:(NSString *)subnodeTag
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];
    
    attributes[@"name"] = databaseNode.nodeName;
    
    if (databaseNode.isDeprecated)
    {
        attributes[@"isDeprecated"] = @YES;
    }
    
    [_xmlWriter tag:subnodeTag attributes:attributes];
}

- (void)_exportGroupNode:(AKGroupNode *)groupNode usingSubnodeTag:(NSString *)subnodeTag
{
    [_xmlWriter tag:@"group" attributes:@{ @"name": groupNode.nodeName } contentBlock:^{
        for (AKDatabaseNode *subnode in [AKSortUtils arrayBySortingArray:[groupNode subnodes]])
        {
            [self _exportGroupSubnode:subnode withXMLTag:subnodeTag];
        }
    }];
}

#pragma mark -
#pragma mark Private methods -- low-level utilities

- (NSString *)_spreadString:(NSString *)s
{
    NSMutableString *result = [NSMutableString string];
    NSInteger numChars = s.length;
    NSInteger i;

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

- (void)_writeLongDividerWithString:(NSString *)aString
{
    NSString *commentString = [NSString stringWithFormat:@"========== [ %@ ] ==========",
                               [self _spreadString:aString]];
    [_xmlWriter comment:commentString];
}

- (void)_writeDividerWithString:(NSString *)aString
{
    NSString *commentString = [NSString stringWithFormat:@"===== %@ =====", aString];
    [_xmlWriter comment:commentString];
}

- (void)_writeAltDividerWithString:(NSString *)aString
{
    NSString *commentString = [NSString stringWithFormat:@"===== [%@] =====", aString];
    [_xmlWriter comment:commentString];
}

- (void)_writeDividerWithString:(NSString *)string1
    string:(NSString *)string2
{
    NSString *commentString = [NSString stringWithFormat:@"===== %@ %@ =====", string1, string2];
    [_xmlWriter comment:commentString];
}

- (void)_writeShortDividerWithString:(NSString *)aString
{
    NSString *commentString = [NSString stringWithFormat:@"## %@ ##", aString];
    [_xmlWriter comment:commentString];
}

@end
