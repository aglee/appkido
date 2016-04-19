/*
 * AKCocoaGlobalsDocParser.m
 *
 * Created by Andy Lee on Tue May 17 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKCocoaGlobalsDocParser.h"

#import "DIGSLog.h"

#import "AKBehaviorNode.h"
#import "AKDatabase.h"
#import "AKFileSection.h"
#import "AKGlobalsNode.h"
#import "AKGroupNode.h"

@implementation AKCocoaGlobalsDocParser

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithDatabase:(AKDatabase *)database frameworkName:(NSString *)frameworkName
{
    if ((self = [super initWithDatabase:database frameworkName:frameworkName]))
    {
        _prevToken[0] = '\0';
        _currTokenStart = NULL;
        _currTokenEnd = NULL;
        _prevTokenStart = NULL;
        _prevTokenEnd = NULL;
    }

    return self;
}

#pragma mark -
#pragma mark AKDocParser methods

- (void)applyParseResults
{
    // [agl] TODO Handle files structured like CGGeometry/Reference/reference.html.

    [self _parseGlobalsFromMajorSections];
}

#pragma mark -
#pragma mark DIGSFileProcessor methods

- (BOOL)shouldProcessFile:(NSString *)filePath
{
    if ([[self targetDatabase] classDocumentedInHTMLFile:filePath]
        || [[self targetDatabase] protocolDocumentedInHTMLFile:filePath])
    {
        // Don't process the file if it's already been processed as a
        // behavior doc.  This is to catch the case where the docset index
        // categorizes a file as both a class doc and a globals doc because
        // it contains a "Constants" section.
        return NO;
    }

    return [super shouldProcessFile:filePath];
}

#pragma mark -
#pragma mark Private methods

// Parse the file in the case where each major section corresponds to a
// group of types/constants.
- (void)_parseGlobalsFromMajorSections
{
    // Iterate through major sections.  Each major section corresponds
    // to a group of types/constants.
    for (AKFileSection *majorSection in [_rootSectionOfCurrentFile childSections])
    {
        if ([[majorSection sectionName] isEqualToString:@"Constants"]
             || [[majorSection sectionName] isEqualToString:@"Data Types"])
        {
            [self _parseGlobalsGroupFromFileSection:majorSection
                                     usingGroupName:[majorSection sectionName]];
        }
    }
}

// Each subsection of the given section contains one global.
- (void)_parseGlobalsGroupFromFileSection:(AKFileSection *)groupSection
                           usingGroupName:(NSString *)groupName
{
    // Get the globals group node corresponding to this major section.
    // Create it if necessary.
    AKGroupNode *groupNode = [[self targetDatabase] globalsGroupNamed:groupName
                                               inFrameworkNamed:[self targetFrameworkName]];
    if (!groupNode)
    {
        groupNode = [AKGroupNode nodeWithNodeName:groupName
                                         database:[self targetDatabase]
                                    frameworkName:[self targetFrameworkName]];
        // [agl] FIXME -- There is a slight flaw in this reasoning: the
        // nodes in a globals group may come from multiple files, so it's
        // not quite right to assign the group a single doc file section.
        [groupNode setNodeDocumentation:groupSection];
        [[self targetDatabase] addGlobalsGroup:groupNode];
    }

    // Iterate through child sections.  Each child section corresponds
    // to a type/constant within the group.
    for (AKFileSection *childSection in [groupSection childSections])
    {
        // Create a globals node and add it to the group.
        AKGlobalsNode *globalsNode = [self _globalsNodeFromFileSection:childSection];

        [globalsNode setNodeDocumentation:childSection];
        [groupNode addSubnode:globalsNode];
    }
}

- (AKGlobalsNode *)_globalsNodeFromFileSection:(AKFileSection *)fileSection
{
    // See if the file we're parsing is a behavior doc.  Relies on the
    // assumption that if so, the doc was already parsed as such and is
    // therefore known to the database.
    id behaviorNode = [[self targetDatabase] classDocumentedInHTMLFile:[fileSection filePath]];

    if (behaviorNode == nil)
    {
        behaviorNode = [[self targetDatabase] protocolDocumentedInHTMLFile:[fileSection filePath]];
    }

    // Create a node.
    NSString *globalsNodeName;

    if (behaviorNode == nil)
    {
        globalsNodeName = [self _modifyGlobalsNodeName:[fileSection sectionName]];
    }
    else if ([behaviorNode isClassNode])
    {
        globalsNodeName = [NSString stringWithFormat:@"%@ [%@]",
                           [fileSection sectionName], [behaviorNode nodeName]];
    }
    else
    {
        globalsNodeName = [NSString stringWithFormat:@"%@ <%@>",
                           [fileSection sectionName], [behaviorNode nodeName]];
    }

    AKGlobalsNode *globalsNode = [[AKGlobalsNode alloc] initWithNodeName:globalsNodeName
                                                                 database:[self targetDatabase]
                                                            frameworkName:[self targetFrameworkName]];

    // Add any individual names we find in the minor section.
    for (NSString *nameOfGlobal in [self _parseNamesOfGlobalsInFileSection:fileSection])
    {
        [globalsNode addNameOfGlobal:nameOfGlobal];
    }
    
    // [agl] 2012-07-16 I noticed NSCocoaErrorDomain wasn't getting added, among lots of
    // other constants. Seems I now need to go another level deep to parse those.
    for (AKFileSection *fs in [fileSection childSections])
    {
        for (NSString *name in [self _parseNamesOfGlobalsInFileSection:fs])
        {
            [globalsNode addNameOfGlobal:name];
        }
    }

    // Return the result.
    return globalsNode;
}

// We append the doc title to the globals node name to ensure uniqueness.
// Example: under ApplicationServices > Types & Constants > Constants,
// "Color Modes" appears twice because there are two doc files with the same
// section name.
- (NSString *)_modifyGlobalsNodeName:(NSString *)globalsNodeName
{
    NSString *docTitle = [[self rootSectionOfCurrentFile] sectionName];
    NSMutableArray *titleComponents = [[docTitle componentsSeparatedByString:@" "] mutableCopy];

    [titleComponents removeObject:@"Reference"];
    docTitle = [titleComponents componentsJoinedByString:@" "];
    
    return [NSString stringWithFormat:@"%@ (%@)", globalsNodeName, docTitle];
}

- (NSSet *)_parseNamesOfGlobalsInFileSection:(AKFileSection *)fileSection
{
    NSMutableSet *namesOfGlobals = [NSMutableSet set];
    const char *originalCurrent = _current;
    const char *originalDataEnd = _dataEnd;

    _current = _dataStart + [fileSection sectionOffset];
    _dataEnd = _current + [fileSection sectionLength];

    _prevToken[0] = '\0';
    _currTokenStart = NULL;
    _currTokenEnd = NULL;
    _prevTokenStart = NULL;
    _prevTokenEnd = NULL;

    while (([self _privatelyParseNonMarkupToken]))
    {
        if (strcmp(_token, "enum") == 0)
        {
            // We will end up adding one enum name for each comma or
            // we encounter, plus *possibly* one more for the closing
            // brace.  C allows an extra comma before the closing
            // brace.
            BOOL sawEqualsSign = NO;
            while (([self _privatelyParseNonMarkupToken]))
            {
                if (strcmp(_token, "=") == 0)
                {
                    // We are in the middle of an "enumName = enumValue"
                    // expression.  The previous token, the one before
                    // the equals sign, was the enum name.
                    [namesOfGlobals addObject:[NSString stringWithUTF8String:_prevToken]];
                    sawEqualsSign = YES;
                }
                else if (strcmp(_token, ",") == 0)
                {
                    // If we saw an equals sign, then we already
                    // processed the enum name.  Otherwise, the token
                    // before the comma is the enum name.
                    if (sawEqualsSign)
                    {
                        sawEqualsSign = NO;
                    }
                    else
                    {
                        [namesOfGlobals addObject:[NSString stringWithUTF8String:_prevToken]];
                    }
                }
                else if (strcmp(_token, "}") == 0)
                {
                    // We've hit the closing brace.  Check whether there
                    // have been any tokens since the most recent comma.
                    if (!sawEqualsSign && !(strcmp(_prevToken, ",") == 0))
                    {
                        [namesOfGlobals addObject:[NSString stringWithUTF8String:_prevToken]];
                    }
                    break;
                }
            }
        }
        else if (strcmp(_token, "struct") == 0)
        {
            while (([self _privatelyParseNonMarkupToken]))
            {
                if (strcmp(_token, "}") == 0)
                {
                    break;
                }
            }
        }
        else if (strcmp(_token, "extern") == 0)
        {
            while (([self _privatelyParseNonMarkupToken]))
            {
                if (strcmp(_token, ";") == 0)
                {
                    [namesOfGlobals addObject:[NSString stringWithUTF8String:_prevToken]];
                    break;
                }
            }
        }
        else if ((strcmp(_token, "define") == 0)
                 && (strcmp(_prevToken, "#") == 0))
        {
            (void)[self _privatelyParseNonMarkupToken];
            [namesOfGlobals addObject:[NSString stringWithUTF8String:_token]];
        }
        else if (strcmp(_token, ";") == 0)
        {
            // This will get typedefs as well as implicit externs,
            // but that's okay.
            if (strlen(_prevToken) > 1)  // is not, for example, "}"
            {
                char firstChar = _prevToken[0];

                // Rule out, for example, HTML entities like "&#8220;".
                if (!isdigit(firstChar))
                {
                    [namesOfGlobals addObject:[NSString stringWithUTF8String:_prevToken]];
                }
            }

        }
        else if ((strcmp(_token, "pre") == 0)
                 && (strcmp(_prevToken, "/") == 0))
        {
            break;
        }
    }

    // Clean up pointer ivars.
    _current = originalCurrent;
    _dataEnd = originalDataEnd;

    _prevToken[0] = '\0';
    _currTokenStart = NULL;
    _currTokenEnd = NULL;
    _prevTokenStart = NULL;
    _prevTokenEnd = NULL;

    // Return our results
    return namesOfGlobals;
}

- (BOOL)_privatelyParseNonMarkupToken
{
    strcpy(_prevToken, _token);
    _prevTokenStart = _currTokenStart;
    _prevTokenEnd = _currTokenEnd;
    _currTokenStart = _current;

    BOOL gotToken = [super parseNonMarkupToken];

    _currTokenEnd = _current;

    return gotToken;
}

@end

