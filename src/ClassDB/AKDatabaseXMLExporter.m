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


#pragma mark -
#pragma mark Forward declarations of private methods

@interface AKDatabaseXMLExporter (Private)

- (void)_performSelector:(SEL)aSelector onStrings:(NSArray *)strings;
- (void)_performSelector:(SEL)aSelector onNodes:(NSArray *)nodes;
- (void)_performSelector:(SEL)aSelector
    onNodes:(NSArray *)nodes
    with:(id)arg;

- (NSString *)_spreadString:(NSString *)s;

- (void)_writeLongDividerWithString:(NSString *)aString;
- (void)_writeDividerWithString:(NSString *)aString;
- (void)_writeAltDividerWithString:(NSString *)aString;
- (void)_writeDividerWithString:(NSString *)string1
    string:(NSString *)string2;
- (void)_writeShortDividerWithString:(NSString *)aString;

@end


@implementation AKDatabaseXMLExporter


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithDatabase:(AKDatabase *)database
               fileURL:(NSURL *)outfileURL;
{
    if ((self = [super init]))
    {
        _database = database;
        _xmlWriter = [[TCMXMLWriter alloc] initWithOptions:TCMXMLWriterOptionOrderedAttributes | TCMXMLWriterOptionPrettyPrinted
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
        [self _performSelector:@selector(exportFrameworkNamed:)
                     onStrings:[_database frameworkNames]];
    }];
}


#pragma mark -
#pragma mark Exporting -- members

- (void)exportMembers:(NSString *)membersType
    ofBehavior:(AKBehaviorNode *)behaviorNode
    usingGetSelector:(SEL)getSelector
    xmlTag:(NSString *)memberTag
{
    [_xmlWriter tag:membersType attributes:nil contentBlock:^{
        [self
         _performSelector:@selector(exportMember:withXMLTag:)
         onNodes:[behaviorNode performSelector:getSelector]
         with:memberTag];
    }];
}

- (void)exportMember:(AKMemberNode *)memberNode
    withXMLTag:(NSString *)memberTag
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity:2];
    [attributes setObject:[memberNode nodeName] forKey:@"name"];
    if ([memberNode isDeprecated]) {
        [attributes setObject:[NSNumber numberWithBool:YES] forKey:@"isDeprecated"];
    }
    [_xmlWriter tag:memberTag attributes:attributes];
}


#pragma mark -
#pragma mark Exporting -- classes and protocols

- (void)exportClass:(AKClassNode *)classNode
{
    [_xmlWriter tag:@"class" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[classNode nodeName],@"name", nil] contentBlock:^{
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
    }];
}

- (void)exportProtocol:(AKProtocolNode *)protocolNode
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity:2];
    [attributes setObject:[protocolNode nodeName] forKey:@"name"];
    [attributes setObject:([protocolNode isInformal] ? @"informal" : @"formal") forKey:@"type"];
    [_xmlWriter tag:@"protocol" attributes:attributes contentBlock:^{
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
    }];
}


#pragma mark -
#pragma mark Exporting -- group nodes

- (void)exportGroupSubnode:(AKDatabaseNode *)databaseNode
    withXMLTag:(NSString *)subnodeTag
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity:2];
    [attributes setObject:[databaseNode nodeName] forKey:@"name"];
    if ([databaseNode isDeprecated]) {
        [attributes setObject:[NSNumber numberWithBool:YES] forKey:@"isDeprecated"];
    }
    [_xmlWriter tag:subnodeTag attributes:attributes];
}

- (void)exportGroupNode:(AKGroupNode *)groupNode
    usingSubnodeTag:(NSString *)subnodeTag
{
    [_xmlWriter tag:@"group" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[groupNode nodeName],@"name", nil] contentBlock:^{
        [self _performSelector:@selector(exportGroupSubnode:withXMLTag:)
                       onNodes:[groupNode subnodes]
                          with:subnodeTag];
    }];
}


#pragma mark -
#pragma mark Exporting -- frameworks

- (void)exportNodesInSection:(NSString *)frameworkSection
    ofFramework:(NSString *)fwName
    usingGetSelector:(SEL)getSelector
    exportSelector:(SEL)exportSelector
{
    [self _writeDividerWithString:fwName string:frameworkSection];
    [_xmlWriter tag:frameworkSection attributes:nil contentBlock:^{
        [self _performSelector:exportSelector
                       onNodes:[_database performSelector:getSelector withObject:fwName]];
    }];
}

- (void)exportProtocolsForFramework:(NSString *)fwName
{
    [_xmlWriter tag:@"protocols" attributes:nil contentBlock:^{
        [self _writeDividerWithString:fwName string:@"formal protocols"];
        [self _performSelector:@selector(exportProtocol:)
                       onNodes:[_database formalProtocolsForFrameworkNamed:fwName]];
        
        // Write informal protocols.
        [self _writeDividerWithString:fwName string:@"informal protocols"];
        [self _performSelector:@selector(exportProtocol:)
                       onNodes:[_database informalProtocolsForFrameworkNamed:fwName]];
    }];
}

- (void)exportGroupNodesInSection:(NSString *)frameworkSection
    ofFramework:(NSString *)fwName
    usingGetSelector:(SEL)getSelector
    subnodeTag:(NSString *)subnodeTag
{
    [self _writeDividerWithString:fwName string:frameworkSection];
    [_xmlWriter tag:frameworkSection attributes:nil contentBlock:^{
        [self
            _performSelector:@selector(exportGroupNode:usingSubnodeTag:)
            onNodes:[_database performSelector:getSelector withObject:fwName]
            with:subnodeTag];

    }];
}

- (void)exportFrameworkNamed:(NSString *)fwName
{
    [self _writeLongDividerWithString:fwName];
    [_xmlWriter tag:@"framework" attributes:[NSDictionary dictionaryWithObjectsAndKeys:fwName,@"name", nil] contentBlock:^{
        [_xmlWriter tag:@"classes" attributes:nil contentBlock:^{
            // export all classes now
            for (AKClassNode *classNode in [_database classesForFrameworkNamed:fwName]) {
                [self exportClass:classNode];
            }
        }];
        [self exportProtocolsForFramework:fwName];
        [self
            exportGroupNodesInSection:@"functions"
            ofFramework:fwName
            usingGetSelector:@selector(functionsGroupsForFrameworkNamed:)
            subnodeTag:@"function"];
        [self
            exportGroupNodesInSection:@"globals"
            ofFramework:fwName
            usingGetSelector:@selector(globalsGroupsForFrameworkNamed:)
            subnodeTag:@"global"];
    }];
}


#pragma mark -
#pragma mark Low-level utility methods

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
    NSString *commentString = [[NSString alloc] initWithFormat:@"========== [ %@ ] ==========",[self _spreadString:aString]];
    [_xmlWriter comment:commentString];
}

- (void)_writeDividerWithString:(NSString *)aString
{
    NSString *commentString = [[NSString alloc] initWithFormat:@"===== %@ =====",aString];
    [_xmlWriter comment:commentString];
}

- (void)_writeAltDividerWithString:(NSString *)aString
{
    NSString *commentString = [[NSString alloc] initWithFormat:@"===== [%@] =====",aString];
    [_xmlWriter comment:commentString];
}

- (void)_writeDividerWithString:(NSString *)string1
    string:(NSString *)string2
{
    NSString *commentString = [[NSString alloc] initWithFormat:@"===== %@ %@ =====",string1, string2];
    [_xmlWriter comment:commentString];
}

- (void)_writeShortDividerWithString:(NSString *)aString
{
    NSString *commentString = [[NSString alloc] initWithFormat:@"## %@ ##",aString];
    [_xmlWriter comment:commentString];
}

@end
