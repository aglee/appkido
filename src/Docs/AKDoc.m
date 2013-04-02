/*
 * AKDoc.m
 *
 * Created by Andy Lee on Mon Mar 15 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDoc.h"

#import <WebKit/WebKit.h>

#import "DIGSLog.h"

#import "AKDocParser.h"
#import "AKFileSection.h"

@implementation AKDoc

#pragma mark -
#pragma mark Getters and setters

- (AKFileSection *)fileSection
{
    DIGSLogError_MissingOverride();
    return nil;
}

- (BOOL)docTextIsHTML
{
    return YES;
}

- (BOOL)docTextShouldIncludeDescendantSections
{
    return YES;
}

- (NSData *)docTextData
{
    AKFileSection *fileSection = [self fileSection];

    if ([self docTextIsHTML])
    {
        NSData *textData = ([self docTextShouldIncludeDescendantSections]
                            ? [self _rolledUpTextForFileSection:fileSection]
                            : [fileSection sectionData]);

        return [self _kludgeHTML:textData];
    }
    else
    {
        return [fileSection sectionData];
    }
}

- (NSString *)docName
{
    return [[self fileSection] sectionName];
}

- (NSString *)stringToDisplayInDocList
{
// Calling ak_stripHTML makes the display sluggish when the doc list
// contains hundreds of entries (e.g., Foundation -> Types & Constants).
//    return [[self docName] ak_stripHTML];
    return [self docName];
}

- (NSString *)commentString
{
    return @"";
}

#pragma mark -
#pragma mark NSObject methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: docName=%@>", [self className], [self docName]];
}

#pragma mark -
#pragma mark Private methods

- (NSData *)_rolledUpTextForFileSection:(AKFileSection *)fileSection
{
    // Put all the file sections we want to roll up into an array.
    NSMutableArray *sectionArray = [NSMutableArray arrayWithObject:fileSection];

    [self _addDescendantSectionsOf:fileSection depthFirstToArray:sectionArray];

    // Concatenate the text from all the sections.
    NSMutableData *rolledUpData = [NSMutableData data];

    for (AKFileSection *elem in sectionArray)
    {
        [rolledUpData appendData:[elem sectionData]];
    }

    return rolledUpData;
}

- (void)_addDescendantSectionsOf:(AKFileSection *)fileSection
               depthFirstToArray:(NSMutableArray *)sectionArray
{
    NSInteger numSubs = [fileSection numberOfChildSections];

    if (numSubs == 0)
    {
        return;
    }

    NSInteger i;
    for (i = 0; i < numSubs; i++)
    {
        AKFileSection *sub = [fileSection childSectionAtIndex:i];

        [sectionArray addObject:sub];
        [self _addDescendantSectionsOf:sub depthFirstToArray:sectionArray];
    }
}

- (NSData *)_kludgeHTML:(NSData *)htmlData
{
    NSMutableData *sourceData =
        [NSMutableData dataWithCapacity:([htmlData length] + 1)];

    // Add a null terminator to the source data so it contains a
    // C string.
    [sourceData setData:htmlData];
    [sourceData setLength:([sourceData length] + 1)];

    // ===== KLUDGE #3: get rid of trailing Apple copyright =====

    [self _kludgeThree:sourceData];

    // ===== KLUDGE #4: get rid of trailing <hr> =====

    [self _kludgeFour:sourceData];

    // ===== KLUDGE #5: see +[AKDocParser kludgeHTMLForTiger] =====

    sourceData = [self _kludgeFive:sourceData];

    // We're done kludging.
    return sourceData;
}

- (NSMutableData *)_kludgeOne:(NSData *)sourceData
{
    NSMutableData *newHTMLData = [NSMutableData dataWithCapacity:([sourceData length] + 64)];

    // Find all <pre>...</pre> elements in the source HTML.
    char *endOfPreElement = (char *)[sourceData bytes];
    char *startOfPreElement = strstr(endOfPreElement, "<pre>");
    while (startOfPreElement)
    {
        // Append the non-<pre> text we just skipped to the new HTML.
        [newHTMLData
            appendBytes:endOfPreElement
            length:(startOfPreElement - endOfPreElement)];

        // Find the closing </pre> that matches the opening <pre> we found.
        endOfPreElement = strstr(startOfPreElement + 5, "</pre>");
        if (!endOfPreElement)
        {
            DIGSLogWarning(@"odd -- couldn't find a closing </pre> tag");
            break;
        }

        // Append <code> to the new HTML to replace <pre>.
        [newHTMLData appendBytes:"<code>" length:6];

        // Process each character in the source HTML between the opening
        // <pre> and the closing </pre>.  For each character, decide what
        // to append to the new HTML.
        char *cp;
        for (cp = startOfPreElement + 5; cp < endOfPreElement; cp++)
        {
            char c = *cp;
            BOOL isNewLine = YES;

            if (c == ' ')
            {
                // Replace each *leading* space on a line with &nbsp;.
                if (isNewLine)
                {
                    [newHTMLData appendBytes:"&nbsp;" length:6];
                }
                else
                {
                    [newHTMLData appendBytes:cp length:1];
                }
            }
            else if (c == '\n')
            {
                // Replace \n with <br>.
                [newHTMLData appendBytes:"<br>" length:4];
//                isNewLine = YES;
            }
            else if (c == '\r')
            {
                // Discard \r characters.
//                isNewLine = YES;
            }
            else
            {
                // Copy the source character as is.
                [newHTMLData appendBytes:cp length:1];
//                isNewLine = NO;
            }
        }

        // Append </code> to the new HTML to replace </pre>.
        [newHTMLData appendBytes:"</code>" length:7];

        // Prepare for next loop iteration.
        endOfPreElement = endOfPreElement + 6;  // skip over the </pre>
        startOfPreElement = strstr(endOfPreElement, "<pre>");
    }

    // Add the remaining non-<pre> text.  There will be at least one byte
    // of non-<pre> text, namely the NULL terminator.
    [newHTMLData appendBytes:endOfPreElement
                      length:((char *)[sourceData bytes] + [sourceData length] - endOfPreElement)];

    return newHTMLData;
}

- (void)_kludgeThree:(NSMutableData *)sourceData
{
    // Find the last copyright symbol in the text.
    char *dataPtr = (char *)[sourceData bytes];
    char *copyrightPtr = NULL;

    while ((dataPtr = strstr(dataPtr, "&#169;")))
    {
        copyrightPtr = dataPtr;

        // Prepare for next loop iteration by skipping over the copyright
        // symbol.
        dataPtr += 6;
    }

    // Truncate the text at the copyright symbol.
    if (copyrightPtr)
    {
        [sourceData setLength:(copyrightPtr - (char *)[sourceData bytes])];

        // Add NULL termination by incrementing data length.
        [sourceData setLength:([sourceData length] + 1)];
    }
}

- (void)_kludgeFour:(NSMutableData *)sourceData
{
    const char *dataStart = (const char *)[sourceData bytes];

    // Find the last <hr> tag in the text.  Note that we search for "<hr"
    // rather than "<hr>", because it might be a tag like <hr WIDTH=...>.
    const char *dataPtr = dataStart;
    const char *lastHRPtr = NULL;

    while ((dataPtr = strstr(dataPtr, "<hr")))
    {
        lastHRPtr = dataPtr;

        // Prepare for next loop iteration by skipping over the <hr>.
        dataPtr += 4;
    }

    // If there is an <hr> tag, see if we should truncate the text to
    // exclude the <hr> and everything after it.
    if (lastHRPtr)
    {
        // If there's only whitespace and HTML tags after the <hr>,
        // then we want to truncate the text.
        BOOL shouldTruncateAfterHR = YES;
        BOOL isInsideTag = NO;

        for (dataPtr = lastHRPtr; *dataPtr != '\0'; dataPtr++)
        {
            char c = *dataPtr;

            if (c == '\0')
            {
                break;
            }
            else if (isspace(c))
            {
                // Continue.
            }
            else if (c == '<')
            {
                isInsideTag = YES;
            }
            else if (c == '>')
            {
                isInsideTag = NO;
            }
            else if (!isInsideTag)
            {
                shouldTruncateAfterHR = NO;
                break;
            }
        }

        // Truncate at the appropriate point, if any.
        if (shouldTruncateAfterHR)
        {
            [sourceData setLength:(lastHRPtr - dataStart)];

            // Add NULL termination by incrementing data length.
            [sourceData setLength:([sourceData length] + 1)];
        }
    }
}

- (NSMutableData *)_kludgeFive:(NSData *)sourceData
{
    return [AKDocParser kludgeHTMLForTiger:sourceData];
}

@end
