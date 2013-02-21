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

@implementation AKDatabaseXMLExporter

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithDatabase:(AKDatabase *)database fileURL:(NSURL *)outfileURL;
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

- (id)init
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
        [self _performSelector:@selector(_exportFrameworkNamed:)
                     onStrings:[_database frameworkNames]];
    }];
}


#pragma mark -
#pragma mark Private methods -- exporting members

- (void)_exportMembers:(NSString *)membersType
            ofBehavior:(AKBehaviorNode *)behaviorNode
      usingGetSelector:(SEL)getSelector
                xmlTag:(NSString *)memberTag
{
    [_xmlWriter tag:membersType attributes:nil contentBlock:^{
        [self _performSelector:@selector(_exportMember:withXMLTag:)
                       onNodes:[behaviorNode performSelector:getSelector]
                          with:memberTag];
    }];
}

- (void)_exportMember:(AKMemberNode *)memberNode withXMLTag:(NSString *)memberTag
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity:2];

    [attributes setObject:[memberNode nodeName] forKey:@"name"];

    if ([memberNode isDeprecated])
    {
        [attributes setObject:[NSNumber numberWithBool:YES] forKey:@"isDeprecated"];
    }

    [_xmlWriter tag:memberTag attributes:attributes];
}


#pragma mark -
#pragma mark Private methods -- exporting classes and protocols

- (void)_exportClass:(AKClassNode *)classNode
{
    [_xmlWriter tag:@"class" attributes:@{ @"name": [classNode nodeName] } contentBlock:^{
        [self _exportMembers:@"properties"
                  ofBehavior:classNode
            usingGetSelector:@selector(documentedProperties)
                      xmlTag:@"property"];

        [self _exportMembers:@"classmethods"
                  ofBehavior:classNode
            usingGetSelector:@selector(documentedClassMethods)
                      xmlTag:@"method"];

        [self _exportMembers:@"instancemethods"
                  ofBehavior:classNode
            usingGetSelector:@selector(documentedInstanceMethods)
                      xmlTag:@"method"];

        [self _exportMembers:@"delegatemethods"
                  ofBehavior:classNode
            usingGetSelector:@selector(documentedDelegateMethods)
                      xmlTag:@"method"];

        [self _exportMembers:@"notifications"
                  ofBehavior:classNode
            usingGetSelector:@selector(documentedNotifications)
                      xmlTag:@"notification"];
    }];
}

- (void)_exportProtocol:(AKProtocolNode *)protocolNode
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity:2];

    [attributes setObject:[protocolNode nodeName] forKey:@"name"];
    [attributes setObject:([protocolNode isInformal] ? @"informal" : @"formal") forKey:@"type"];
    
    [_xmlWriter tag:@"protocol" attributes:attributes contentBlock:^{
        [self _exportMembers:@"properties"
                  ofBehavior:protocolNode
            usingGetSelector:@selector(documentedProperties)
                      xmlTag:@"property"];

        [self _exportMembers:@"classmethods"
                  ofBehavior:protocolNode
            usingGetSelector:@selector(documentedClassMethods)
                      xmlTag:@"method"];

        [self _exportMembers:@"instancemethods"
                  ofBehavior:protocolNode
            usingGetSelector:@selector(documentedInstanceMethods)
                      xmlTag:@"method"];
    }];
}


#pragma mark -
#pragma mark Private methods -- exporting group nodes

- (void)_exportGroupSubnode:(AKDatabaseNode *)databaseNode withXMLTag:(NSString *)subnodeTag
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [attributes setObject:[databaseNode nodeName] forKey:@"name"];
    
    if ([databaseNode isDeprecated])
    {
        [attributes setObject:[NSNumber numberWithBool:YES] forKey:@"isDeprecated"];
    }
    
    [_xmlWriter tag:subnodeTag attributes:attributes];
}

- (void)_exportGroupNode:(AKGroupNode *)groupNode usingSubnodeTag:(NSString *)subnodeTag
{
    [_xmlWriter tag:@"group" attributes:@{ @"name": [groupNode nodeName] } contentBlock:^{
        [self _performSelector:@selector(_exportGroupSubnode:withXMLTag:)
                       onNodes:[groupNode subnodes]
                          with:subnodeTag];
    }];
}


#pragma mark -
#pragma mark Private methods -- exporting frameworks

//- (void)_exportNodesInSection:(NSString *)frameworkSection
//                  ofFramework:(NSString *)fwName
//             usingGetSelector:(SEL)getSelector
//               exportSelector:(SEL)exportSelector
//{
//    [self _writeDividerWithString:fwName string:frameworkSection];
//    [_xmlWriter tag:frameworkSection attributes:nil contentBlock:^{
//        [self _performSelector:exportSelector
//                       onNodes:[_database performSelector:getSelector withObject:fwName]];
//    }];
//}

- (void)_exportProtocolsForFramework:(NSString *)fwName
{
    [_xmlWriter tag:@"protocols" attributes:nil contentBlock:^{
        [self _writeDividerWithString:fwName string:@"formal protocols"];
        [self _performSelector:@selector(_exportProtocol:)
                       onNodes:[_database formalProtocolsForFrameworkNamed:fwName]];
        
        // Write informal protocols.
        [self _writeDividerWithString:fwName string:@"informal protocols"];
        [self _performSelector:@selector(_exportProtocol:)
                       onNodes:[_database informalProtocolsForFrameworkNamed:fwName]];
    }];
}

- (void)_exportGroupNodesInSection:(NSString *)frameworkSection
                       ofFramework:(NSString *)fwName
                  usingGetSelector:(SEL)getSelector
                        subnodeTag:(NSString *)subnodeTag
{
    [self _writeDividerWithString:fwName string:frameworkSection];
    [_xmlWriter tag:frameworkSection attributes:nil contentBlock:^{
        [self _performSelector:@selector(_exportGroupNode:usingSubnodeTag:)
                       onNodes:[_database performSelector:getSelector withObject:fwName]
                          with:subnodeTag];

    }];
}

- (void)_exportFrameworkNamed:(NSString *)fwName
{
    [self _writeLongDividerWithString:fwName];
    [_xmlWriter tag:@"framework" attributes:@{ @"name": fwName } contentBlock:^{
        [_xmlWriter tag:@"classes" attributes:nil contentBlock:^{
            // export all classes now
            for (AKClassNode *classNode in [_database classesForFrameworkNamed:fwName]) {
                [self _exportClass:classNode];
            }
        }];
        
        [self _exportProtocolsForFramework:fwName];

        [self _exportGroupNodesInSection:@"functions"
                             ofFramework:fwName
                        usingGetSelector:@selector(functionsGroupsForFrameworkNamed:)
                              subnodeTag:@"function"];

        [self _exportGroupNodesInSection:@"globals"
                             ofFramework:fwName
                        usingGetSelector:@selector(globalsGroupsForFrameworkNamed:)
                              subnodeTag:@"global"];
    }];
}


#pragma mark -
#pragma mark Private methods -- low-level utilities

- (void)_performSelector:(SEL)aSelector onStrings:(NSArray *)strings
{
    for (NSObject *element in [strings sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)])
    {
        [self performSelector:aSelector withObject:element];
    }
}

- (void)_performSelector:(SEL)aSelector onNodes:(NSArray *)nodes
{
    for (NSObject *element in [AKSortUtils arrayBySortingArray:nodes])
    {
        [self performSelector:aSelector withObject:element];
    }
}

- (void)_performSelector:(SEL)aSelector onNodes:(NSArray *)nodes with:(id)arg
{
    for (NSObject *element in [AKSortUtils arrayBySortingArray:nodes])
    {
        [self performSelector:aSelector withObject:element withObject:arg];
    }
}

- (NSString *)_spreadString:(NSString *)s
{
    NSMutableString *result = [NSMutableString string];
    NSInteger numChars = [s length];
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
    NSString *commentString = [[NSString alloc] initWithFormat:@"========== [ %@ ] ==========",
                               [self _spreadString:aString]];
    [_xmlWriter comment:commentString];
}

- (void)_writeDividerWithString:(NSString *)aString
{
    NSString *commentString = [[NSString alloc] initWithFormat:@"===== %@ =====", aString];
    [_xmlWriter comment:commentString];
}

- (void)_writeAltDividerWithString:(NSString *)aString
{
    NSString *commentString = [[NSString alloc] initWithFormat:@"===== [%@] =====", aString];
    [_xmlWriter comment:commentString];
}

- (void)_writeDividerWithString:(NSString *)string1
    string:(NSString *)string2
{
    NSString *commentString = [[NSString alloc] initWithFormat:@"===== %@ %@ =====", string1, string2];
    [_xmlWriter comment:commentString];
}

- (void)_writeShortDividerWithString:(NSString *)aString
{
    NSString *commentString = [[NSString alloc] initWithFormat:@"## %@ ##", aString];
    [_xmlWriter comment:commentString];
}

@end
