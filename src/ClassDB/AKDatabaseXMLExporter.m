/*
 *  AKDatabaseXMLExporter.m
 *  AppKiDo
 *
 *  Created by Andy Lee on 12/31/07.
 *  Copyright 2007 Andy Lee. All rights reserved.
 */

#import "AKDatabaseXMLExporter.h"

#import "DIGSLog.h"

#import "AKClassItem.h"
#import "AKDatabase.h"
#import "AKGroupItem.h"
#import "AKMemberItem.h"
#import "AKProtocolItem.h"
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
    return [self initWithDatabase:nil fileURL:nil];
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
            NSArray *allClassItems = [_database classesForFrameworkNamed:fwName];
            for (AKClassItem *classItem in [AKSortUtils arrayBySortingArray:allClassItems])
            {
                [self _exportClass:classItem];
            }
        }];

        // Export protocols.
        [self _exportProtocolsForFramework:fwName];

        // Export functions.
        [self _exportGroupItems:[_database functionsGroupsForFrameworkNamed:fwName]
                      inSection:@"functions"
                    ofFramework:fwName
                     subitemTag:@"function"];

        // Export globals.
        [self _exportGroupItems:[_database globalsGroupsForFrameworkNamed:fwName]
                      inSection:@"globals"
                    ofFramework:fwName
                     subitemTag:@"global"];
    }];
}

- (void)_exportProtocolsForFramework:(NSString *)fwName
{
    [_xmlWriter tag:@"protocols" attributes:nil contentBlock:^{
        // Write formal protocols.
        [self _writeDividerWithString:fwName string:@"formal protocols"];

        NSArray *formalProtocols = [_database formalProtocolsForFrameworkNamed:fwName];
        for (AKProtocolItem *protocolItem in [AKSortUtils arrayBySortingArray:formalProtocols])
        {
            [self _exportProtocol:protocolItem];
        }

        // Write informal protocols.
        [self _writeDividerWithString:fwName string:@"informal protocols"];

        NSArray *informalProtocols = [_database informalProtocolsForFrameworkNamed:fwName];
        for (AKProtocolItem *protocolItem in [AKSortUtils arrayBySortingArray:informalProtocols])
        {
            [self _exportProtocol:protocolItem];
        }
    }];
}

- (void)_exportGroupItems:(NSArray *)groupItems
                inSection:(NSString *)frameworkSection
              ofFramework:(NSString *)fwName
               subitemTag:(NSString *)subitemTag
{
    [self _writeDividerWithString:fwName string:frameworkSection];
    [_xmlWriter tag:frameworkSection attributes:nil contentBlock:^{
        for (AKGroupItem *groupItem in [AKSortUtils arrayBySortingArray:groupItems])
        {
            [self _exportGroupItem:groupItem usingsubitemTag:subitemTag];
        }
    }];
}


#pragma mark -
#pragma mark Private methods -- exporting classes and protocols

- (void)_exportClass:(AKClassItem *)classItem
{
    [_xmlWriter tag:@"class" attributes:@{ @"name": classItem.tokenName } contentBlock:^{
        [self _exportMembers:[classItem documentedProperties]
                      ofType:@"properties"
                      xmlTag:@"property"];

        [self _exportMembers:[classItem documentedClassMethods]
                      ofType:@"classmethods"
                      xmlTag:@"method"];

        [self _exportMembers:[classItem documentedInstanceMethods]
                      ofType:@"instancemethods"
                      xmlTag:@"method"];

        [self _exportMembers:[classItem documentedDelegateMethods]
                      ofType:@"delegatemethods"
                      xmlTag:@"method"];

        [self _exportMembers:[classItem documentedNotifications]
                      ofType:@"notifications"
                      xmlTag:@"notification"];
    }];
}

- (void)_exportProtocol:(AKProtocolItem *)protocolItem
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];

    attributes[@"name"] = protocolItem.tokenName;
    attributes[@"type"] = (protocolItem.isInformal ? @"informal" : @"formal");

    [_xmlWriter tag:@"protocol" attributes:attributes contentBlock:^{
        [self _exportMembers:[protocolItem documentedProperties]
                      ofType:@"properties"
                      xmlTag:@"property"];

        [self _exportMembers:[protocolItem documentedClassMethods]
                      ofType:@"classmethods"
                      xmlTag:@"method"];

        [self _exportMembers:[protocolItem documentedInstanceMethods]
                      ofType:@"instancemethods"
                      xmlTag:@"method"];
    }];
}


#pragma mark -
#pragma mark Private methods -- exporting members

- (void)_exportMembers:(NSArray *)memberItems
                ofType:(NSString *)membersType
                xmlTag:(NSString *)memberTag
{
    [_xmlWriter tag:membersType attributes:nil contentBlock:^{
        for (AKMemberItem *memberItem in [AKSortUtils arrayBySortingArray:memberItems])
        {
            [self _exportMember:memberItem withXMLTag:memberTag];
        }
    }];
}

- (void)_exportMember:(AKMemberItem *)memberItem withXMLTag:(NSString *)memberTag
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];

    attributes[@"name"] = memberItem.tokenName;

    if (memberItem.isDeprecated)
    {
        attributes[@"isDeprecated"] = @YES;
    }

    [_xmlWriter tag:memberTag attributes:attributes];
}


#pragma mark -
#pragma mark Private methods -- exporting group nodes

- (void)_exportGroupSubitem:(AKTokenItem *)tokenItem withXMLTag:(NSString *)subitemTag
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];
    
    attributes[@"name"] = tokenItem.tokenName;
    
    if (tokenItem.isDeprecated)
    {
        attributes[@"isDeprecated"] = @YES;
    }
    
    [_xmlWriter tag:subitemTag attributes:attributes];
}

- (void)_exportGroupItem:(AKGroupItem *)groupItem usingsubitemTag:(NSString *)subitemTag
{
    [_xmlWriter tag:@"group" attributes:@{ @"name": groupItem.tokenName } contentBlock:^{
        for (AKTokenItem *subitem in [AKSortUtils arrayBySortingArray:[groupItem subitems]])
        {
            [self _exportGroupSubitem:subitem withXMLTag:subitemTag];
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
