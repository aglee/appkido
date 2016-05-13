/*
 *  AKDatabaseXMLExporter.m
 *  AppKiDo
 *
 *  Created by Andy Lee on 12/31/07.
 *  Copyright 2007 Andy Lee. All rights reserved.
 */

#import "AKDatabaseXMLExporter.h"

#import "DIGSLog.h"

#import "AKClassToken.h"
#import "AKDatabase.h"
#import "AKGroupItem.h"
#import "AKMemberToken.h"
#import "AKProtocolToken.h"
#import "AKSortUtils.h"

@implementation AKDatabaseXMLExporter

#pragma mark - Init/awake/dealloc

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


#pragma mark - The main export method

- (void)doExport
{
    [_xmlWriter instructXMLStandalone];
    [_xmlWriter tag:@"database" attributes:nil contentBlock:^{
        for (NSString *frameworkName in [_database sortedFrameworkNames])
        {
            [self _exportFramework:frameworkName];
        }
    }];
}

#pragma mark - Private methods -- exporting frameworks

- (void)_exportFramework:(NSString *)fwName
{
    [self _writeLongDividerWithString:fwName];
    [_xmlWriter tag:@"framework" attributes:@{ @"name": fwName } contentBlock:^{
        // Export classes.
        [_xmlWriter tag:@"classes" attributes:nil contentBlock:^{
            NSArray *allClassTokens = [_database classesForFramework:fwName];
            for (AKClassToken *classToken in [AKSortUtils arrayBySortingArray:allClassTokens])
            {
                [self _exportClass:classToken];
            }
        }];

        // Export protocols.
        [self _exportProtocolsForFramework:fwName];

        // Export functions.
        [self _exportGroupItems:[_database functionsGroupsForFramework:fwName]
                      inSection:@"functions"
                    ofFramework:fwName
                     subitemTag:@"function"];

        // Export globals.
        [self _exportGroupItems:[_database globalsGroupsForFramework:fwName]
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

        NSArray *formalProtocols = [_database formalProtocolsForFramework:fwName];
        for (AKProtocolToken *protocolToken in [AKSortUtils arrayBySortingArray:formalProtocols])
        {
            [self _exportProtocol:protocolToken];
        }

        // Write informal protocols.
        [self _writeDividerWithString:fwName string:@"informal protocols"];

        NSArray *informalProtocols = [_database informalProtocolsForFramework:fwName];
        for (AKProtocolToken *protocolToken in [AKSortUtils arrayBySortingArray:informalProtocols])
        {
            [self _exportProtocol:protocolToken];
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


#pragma mark - Private methods -- exporting classes and protocols

- (void)_exportClass:(AKClassToken *)classToken
{
    [_xmlWriter tag:@"class" attributes:@{ @"name": classToken.tokenName } contentBlock:^{
        [self _exportMembers:[classToken propertyTokens]
                      ofType:@"properties"
                      xmlTag:@"property"];

        [self _exportMembers:[classToken classMethodTokens]
                      ofType:@"classmethods"
                      xmlTag:@"method"];

        [self _exportMembers:[classToken instanceMethodTokens]
                      ofType:@"instancemethods"
                      xmlTag:@"method"];

        [self _exportMembers:[classToken documentedDelegateMethods]
                      ofType:@"delegatemethods"
                      xmlTag:@"method"];

        [self _exportMembers:[classToken documentedNotifications]
                      ofType:@"notifications"
                      xmlTag:@"notification"];
    }];
}

- (void)_exportProtocol:(AKProtocolToken *)protocolToken
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];

    attributes[@"name"] = protocolToken.tokenName;
    attributes[@"type"] = (protocolToken.isInformal ? @"informal" : @"formal");

    [_xmlWriter tag:@"protocol" attributes:attributes contentBlock:^{
        [self _exportMembers:[protocolToken propertyTokens]
                      ofType:@"properties"
                      xmlTag:@"property"];

        [self _exportMembers:[protocolToken classMethodTokens]
                      ofType:@"classmethods"
                      xmlTag:@"method"];

        [self _exportMembers:[protocolToken instanceMethodTokens]
                      ofType:@"instancemethods"
                      xmlTag:@"method"];
    }];
}


#pragma mark - Private methods -- exporting members

- (void)_exportMembers:(NSArray *)memberTokens
                ofType:(NSString *)membersType
                xmlTag:(NSString *)memberTag
{
    [_xmlWriter tag:membersType attributes:nil contentBlock:^{
        for (AKMemberToken *memberToken in [AKSortUtils arrayBySortingArray:memberTokens])
        {
            [self _exportMember:memberToken withXMLTag:memberTag];
        }
    }];
}

- (void)_exportMember:(AKMemberToken *)memberToken withXMLTag:(NSString *)memberTag
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];

    attributes[@"name"] = memberToken.tokenName;

    if (memberToken.isDeprecated)
    {
        attributes[@"isDeprecated"] = @YES;
    }

    [_xmlWriter tag:memberTag attributes:attributes];
}


#pragma mark - Private methods -- exporting group items

- (void)_exportGroupSubitem:(AKToken *)token withXMLTag:(NSString *)subitemTag
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];
    
    attributes[@"name"] = token.tokenName;
    
    if (token.isDeprecated)
    {
        attributes[@"isDeprecated"] = @YES;
    }
    
    [_xmlWriter tag:subitemTag attributes:attributes];
}

- (void)_exportGroupItem:(AKGroupItem *)groupItem usingsubitemTag:(NSString *)subitemTag
{
    [_xmlWriter tag:@"group" attributes:@{ @"name": groupItem.tokenName } contentBlock:^{
        for (AKToken *subitem in [AKSortUtils arrayBySortingArray:[groupItem subitems]])
        {
            [self _exportGroupSubitem:subitem withXMLTag:subitemTag];
        }
    }];
}

#pragma mark - Private methods -- low-level utilities

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
