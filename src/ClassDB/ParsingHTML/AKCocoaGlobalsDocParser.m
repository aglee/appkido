/*
 * AKCocoaGlobalsDocParser.m
 *
 * Created by Andy Lee on Tue May 17 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKCocoaGlobalsDocParser.h"

#import <DIGSLog.h>

#import "AKTextUtils.h"
#import "AKDatabase.h"
#import "AKFileSection.h"
#import "AKGroupNode.h"
#import "AKGlobalsNode.h"

//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKCocoaGlobalsDocParser (Private)
- (void)_parseGlobalsFromMajorSections;
- (void)_parseGlobalsGroupFromFileSection:(AKFileSection *)groupSection
    usingGroupName:(NSString *)groupName;
- (AKGlobalsNode *)_globalsNodeFromFileSection:(AKFileSection *)fileSection;
- (NSSet *)_parseNamesOfGlobalsInFileSection:(AKFileSection *)fileSection;
- (BOOL)_privatelyParseNonMarkupToken;
@end


@implementation AKCocoaGlobalsDocParser

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithDatabase:(AKDatabase *)db
    frameworkName:(NSString *)frameworkName
{
    if ((self = [super initWithDatabase:db frameworkName:frameworkName]))
    {
        _prevToken[0] = '\0';
        _currTokenStart = NULL;
        _currTokenEnd = NULL;
        _prevTokenStart = NULL;
        _prevTokenEnd = NULL;
    }

    return self;
}

//-------------------------------------------------------------------------
// AKDocParser methods
//-------------------------------------------------------------------------

- (void)applyParseResults
{
    // [agl] TODO Handle files structured like CGGeometry/Reference/reference.html.

    [self _parseGlobalsFromMajorSections];
}

@end

//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation AKCocoaGlobalsDocParser (Private)

// Parse the file in the case where each major section corresponds to a
// group of types/constants.
- (void)_parseGlobalsFromMajorSections
{
    NSEnumerator *majorSectionEnum =
        [_rootSectionOfCurrentFile childSectionEnumerator];
    AKFileSection *majorSection;

    // Iterate through major sections.  Each major section corresponds
    // to a group of types/constants.
    while ((majorSection = [majorSectionEnum nextObject]))
    {
        if ([[majorSection sectionName] isEqualToString:@"Overview"]
            || [[majorSection sectionName] isEqualToString:@"Functions"])
        {
            continue;  // kludge until globals parsing is fixed properly
        }

        // Get the globals nodes from the minor sections.
        NSString *groupName = [majorSection sectionName];

        if ([groupName isEqualToString:@"Data Types"])
        {
            groupName =
                [@"Data Types - "
                    stringByAppendingString:
                        [[_rootSectionOfCurrentFile sectionName] ak_firstWord]];
        }

        [self
            _parseGlobalsGroupFromFileSection:majorSection
            usingGroupName:[majorSection sectionName]];
    }
}

// Each subsection of the given section contains one global.
- (void)_parseGlobalsGroupFromFileSection:(AKFileSection *)groupSection
    usingGroupName:(NSString *)groupName
{
    // Get the globals group node corresponding to this major section.
    // Create it if necessary.
    AKGroupNode *groupNode =
        [_databaseBeingPopulated
            globalsGroupWithName:groupName
            inFramework:_frameworkName];

    if (!groupNode)
    {
        groupNode =
            [[AKGroupNode alloc]
                initWithNodeName:groupName
                owningFramework:_frameworkName];
        // [agl] FIXME -- There is a slight flaw in this reasoning: the
        // nodes in a globals group may come from multiple files, so it's
        // not quite right to assign the group a single doc file section.
        [groupNode setNodeDocumentation:groupSection];
        [_databaseBeingPopulated addGlobalsGroup:groupNode];
    }

    // Iterate through child sections.  Each child section corresponds
    // to a type/constant within the group.
    NSEnumerator *childSectionEnum = [groupSection childSectionEnumerator];
    AKFileSection *childSection;
    while ((childSection = [childSectionEnum nextObject]))
    {
        // Create a globals node and add it to the group.
        AKGlobalsNode *globalsNode =
            [self _globalsNodeFromFileSection:childSection];

        [globalsNode setNodeDocumentation:childSection];
        [groupNode addSubnode:globalsNode];
    }
}

- (AKGlobalsNode *)_globalsNodeFromFileSection:(AKFileSection *)fileSection
{
    // Create a node.
    AKGlobalsNode *globalsNode =
        [[[AKGlobalsNode alloc]
            initWithNodeName:[fileSection sectionName]
            owningFramework:_frameworkName] autorelease];

    // Add any individual names we find in the minor section.
    NSEnumerator *namesOfGlobalsEnum =
        [[self _parseNamesOfGlobalsInFileSection:fileSection]
            objectEnumerator];
    NSString *nameOfGlobal;

    while ((nameOfGlobal = [namesOfGlobalsEnum nextObject]))
    {
        [globalsNode addNameOfGlobal:nameOfGlobal];
    }

    // Return the result.
    return globalsNode;
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
                    [namesOfGlobals addObject:
                        [NSString stringWithUTF8String:_prevToken]];
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
                        [namesOfGlobals addObject:
                            [NSString stringWithUTF8String:_prevToken]];
                    }
                }
                else if (strcmp(_token, "}") == 0)
                {
                    // We've hit the closing brace.  Check whether there
                    // have been any tokens since the most recent comma.
                    if (!sawEqualsSign && !(strcmp(_prevToken, ",") == 0))
                    {
                        [namesOfGlobals addObject:
                            [NSString stringWithUTF8String:_prevToken]];
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
                    [namesOfGlobals addObject:
                        [NSString stringWithUTF8String:_prevToken]];
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
                    [namesOfGlobals addObject:
                        [NSString stringWithUTF8String:_prevToken]];
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

