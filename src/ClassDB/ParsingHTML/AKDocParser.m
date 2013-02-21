/*
 * AKDocParser.m
 *
 * Created by Andy Lee on Mon Jul 08 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKDocParser.h"

#import "DIGSLog.h"
#import "AKTextUtils.h"
#import "AKDatabase.h"
#import "AKFramework.h"
#import "AKFileSection.h"


@implementation AKDocParser


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithFramework:(AKFramework *)aFramework
{
    if ((self = [super initWithFramework:aFramework]))
    {
        _sectionStack = [[NSMutableArray alloc] init];
        _token[0] = '\0';
    }

    return self;
}


#pragma mark -
#pragma mark Parsing

- (BOOL)parseToken
{
    if (_current >= _dataEnd)
    {
        _current = _dataEnd;
        return NO;
    }

    // Skip whitespace.
    // [agl] TODO -- Currently treating bytes with high bit set as whitespace.
    // Might want to properly handle charsets and encodings some time.
    while (isspace(*_current) || (*_current & 0x80))
    {
        _current++;
        if (_current >= _dataEnd)
        {
            _current = _dataEnd;
            return NO;
        }
    }

    const char *tokenStart = _current;
    char ch = *_current;

    if ((!isalnum(ch)) && (ch != '_'))
    {
        // Treat punctuation characters as individual tokens.
        _token[0] = *_current;
        _token[1] = '\0';
        _current++;
        return YES;
    }
    else
    {
        // The token we are parsing is a sequence of characters that are
        // either alphanumeric, the # character, or the underscore.
        while (((ch >= '0') && (ch <= '9'))
                || ((ch >= 'a') && (ch <= 'z'))
                || ((ch >= 'A') && (ch <= 'Z'))
                || (ch == '_'))
        {
            _current++;
            if (_current >= _dataEnd)
            {
                NSInteger len = _dataEnd - tokenStart;

                _current = _dataEnd;
                memcpy(_token, tokenStart, len);
                _token[len] = '\0';
                return YES;
            }
            ch = *_current;
        }

        // If we got this far, we found the end of the token before
        // reaching the end of the input, and cp points to the first
        // character after the token.
        NSInteger len = _current - tokenStart;

        memcpy(_token, tokenStart, len);
        _token[len] = '\0';
        return YES;
    }
}

- (BOOL)parseNonMarkupToken
{
    while ([self parseToken])
    {
        if (strcmp(_token, "<") == 0)
        {
            // Treat HTML tags as if we never saw them.  Skip past
            // the closing angle bracket.
            while (_current < _dataEnd)
            {
                if (*_current == '>')
                {
                    _current++;
                    break;
                }
                else
                {
                    _current++;
                }
            }
        }
        else if (strcmp(_token, "&") == 0)
        {
            // See if we're on an entity.  We SHOULD be, but might
            // as well defensively handle the easier cases where we aren't.
            const char *saveCurrent = _current;

            // Treat entities as if we never saw them.  Skip past
            // the closing semicolon.
            // [agl] not worrying about whitespace for now
            BOOL isEntity = NO;
            if ([self parseToken])
            {
                if ([self parseToken])
                {
                    if (strcmp(_token, ";") == 0)
                    {
                        isEntity = YES;
                    }
                }
            }

            if (!isEntity)
            {
                // We'll have to return the ampersand as the token.
                _current = saveCurrent;
                strcpy(_token, "&");
                return YES;
            }
        }
        else
        {
            // We have a token that is neither inside an HTML tag
            // nor an entity.
            return YES;
        }
    }

    // If we got this far, there was no token.
    return NO;
}


#pragma mark -
#pragma mark DIGSFileProcessor methods

- (BOOL)shouldProcessFile:(NSString *)filePath
{
    return [[filePath pathExtension] isEqualToString:@"html"];
}


#pragma mark -
#pragma mark AKParser methods

- (NSMutableData *)loadDataToBeParsed
{
    NSMutableData *originalData = nil;
    NSMutableData *afterFirstKludge = nil;
    NSMutableData *afterSecondKludge = nil;

    // Load the file.
    originalData = [[NSMutableData alloc] initWithContentsOfFile:[self currentPath]];
    if (!originalData)
    {
        DIGSLogWarning(@"could not load contents of file [%@]", [self currentPath]);
        return nil;
    }

    // Add a NULL terminator so strstr() will work.
    [originalData setLength:([originalData length] + 1)];

    // Perform the first kludge.
    @autoreleasepool
    {
        afterFirstKludge = [[self class] _kludgeDivTagsToH3:originalData];
    }
    originalData = nil;

    // Perform the second kludge.
    @autoreleasepool
    {
        afterSecondKludge = [[self class] _kludgeSpanTagsToH1:afterFirstKludge];
    }
    afterFirstKludge = nil;

    // Remove the NULL terminator, which was copied by the kludge.
    [afterSecondKludge setLength:([afterSecondKludge length] - 1)];

    return afterSecondKludge;
}

- (void)parseCurrentFile
{
    @autoreleasepool
    {
        // Parse the file, to extract the hierarchy of sections therein.
        _rootSectionOfCurrentFile = [self _parseRootSection];

        // Apply the parse results to the database.
        if (_rootSectionOfCurrentFile != nil)
        {
            [[_targetFramework owningDatabase] rememberFrameworkName:[_targetFramework frameworkName]
                                                         forHTMLFile:[self currentPath]];

            [[_targetFramework owningDatabase] rememberRootSection:_rootSectionOfCurrentFile
                                                       forHTMLFile:[self currentPath]];
            
            [self applyParseResults];
        }
    }
}


#pragma mark -
#pragma mark Using parse results

- (AKFileSection *)rootSectionOfCurrentFile
{
    return _rootSectionOfCurrentFile;
}

- (void)applyParseResults
{
    // Do nothing by default.
}


#pragma mark -
#pragma mark Heinous kludge

+ (NSMutableData *)kludgeHTMLForTiger:(NSData *)sourceData
{
    NSMutableData *result = [self _kludgeDivTagsToH3:sourceData];

    result = [self _kludgeSpanTagsToH1:result];

    return result;    
}


#pragma mark -
#pragma mark Private methods

// Called by -parseCurrentFile, which sets up preconditions and cleans up
// afterward. Partitions the current file into a hierarchy of AKFileSections,
// and returns the root section in that hierarchy.
//
// Pseudo-syntax for doc file:
//
//  <hA>rootSection.title</hA>           // where A is probably 1
//      introText
//      zero or more of:
//      <hB>majorSection.title</hB>    // where B > A
//          sectionText
//          zero or more of:
//          <hC>minorSection.title</hC>   // where C > B
//              minorSectionText
//
// We need to remember the ranges and titles of each section.
- (AKFileSection *)_parseRootSection
{
    // Now do the actual parsing.
// [agl] add assertion check for empty _sectionStack
    while (_current < _dataEnd)
    {
        if (_current[0] == '<')
        {
            // We're looking at the opening angle bracket of an HTML tag.
            // See what kind of tag it is.
            char ch = _current[1];

            if ((ch == 'h') || (ch == 'H'))
            {
                // It may be an <h...> tag.
                [self _processHeaderTag];
            }
            else if ((ch == 'a') || (ch == 'A'))
            {
                // It may be an <a ...> tag.
                [self _processAnchorTag];
            }
            else
            {
                // It's some other kind of tag -- ignore it.
                [self _skipPastClosingAngleBracket];
            }
        }
        else
        {
            // We're looking at a character that's nothing special --
            // skip it.
            _current++;
        }
    }

    // The very last header element we parse ranges to the end of
    // the file.
    AKFileSection *stackTop = [self _peekSectionStack];

    if (stackTop != nil)
    {
        NSInteger sectionLength = _dataEnd - _dataStart - [stackTop sectionOffset];

        [stackTop setSectionLength:sectionLength];
    }

    // Roll up any remaining non-root sections on the stack.
    while ([_sectionStack count] > 1)
    {
        [self _rollUpSiblings];
    }

    // Pop the root section we parsed (which should empty the stack)
    // and return it.
    return [self _popSectionStack];
}

- (AKFileSection *)_popSectionStack
{
    NSInteger stackSize = [_sectionStack count];

    if (stackSize == 0)
    {
        return nil;
    }
    else
    {
        AKFileSection *stackTop = [_sectionStack objectAtIndex:(stackSize - 1)];

        [_sectionStack removeLastObject];

        return stackTop;
    }
}

- (AKFileSection *)_peekSectionStack
{
    NSInteger stackSize = [_sectionStack count];

    if (stackSize == 0)
    {
        return nil;
    }
    else
    {
        return [_sectionStack objectAtIndex:(stackSize - 1)];
    }
}

- (char)_headerLevelAtTopOfSectionStack
{
    NSInteger stackSize = [_sectionStack count];

    if (stackSize == 0)
    {
        return '0';
    }
    else
    {
        AKFileSection *stackTop = [_sectionStack objectAtIndex:(stackSize - 1)];

        return _dataStart[[stackTop sectionOffset] + 2];
    }
}

- (void)_rollUpSiblings
{
    NSMutableArray *siblings = [[NSMutableArray alloc] init];  // no release
    char level = [self _headerLevelAtTopOfSectionStack];

    while (level == [self _headerLevelAtTopOfSectionStack])
    {
        AKFileSection *siblingSection = [self _popSectionStack];

        [siblings addObject:siblingSection];
    }

    AKFileSection *parentSection = [self _peekSectionStack];
    NSInteger numSiblings = [siblings count];
    NSInteger i;

    for (i = numSiblings - 1; i >= 0; i--)
    {
        AKFileSection *childSection = [siblings objectAtIndex:i];

        [parentSection addChildSection:childSection];
    }

      // release here
}

// on entry, _current points to the opening angle bracket of an <hX> tag;
// what we do with it depends on whether X is a digit
- (void)_processHeaderTag
{
    const char *startOfOpeningTag = _current;
    char headerLevel = startOfOpeningTag[2];

    // See if we're looking at an <h#> tag or some other tag name that
    // starts with "h".
    if ((headerLevel < '1') || (headerLevel > '9'))
    {
        [self _skipPastClosingAngleBracket];

        return;
    }

    // The beginning of this section is the end of the last section we
    // pushed on the stack.
    AKFileSection *stackTop = [self _peekSectionStack];

    if (stackTop != nil)
    {
        NSInteger sectionLength = startOfOpeningTag - _dataStart - [stackTop sectionOffset];

        [stackTop setSectionLength:sectionLength];
    }

    // If we are jumping up to an ancestor header level, pop the stack
    // until the top matches this header level.  We only want to push
    // descendants and siblings onto the stack.
    while (headerLevel < [self _headerLevelAtTopOfSectionStack])
    {
        [self _rollUpSiblings];
    }

    // Parse the element name (i.e., the text between <h#> and </h#>),
    // and skip past the end of the closing </h#> tag.
    NSString *sectionName = [self _parseTitleAtLevel:headerLevel];
	// JJ Start
	if (sectionName == nil)
	{
		return;
	}
	// JJ End

    // Push a new file section onto the stack, corresponding to the
    // <h#> element we are looking at.  We don't know the length of
    // the section yet, so for now we put 0.  We will fill in the real
    // length later.
    AKFileSection *newFileSection = [AKFileSection withFile:[self currentPath]];

    [newFileSection setSectionName:sectionName];
    [newFileSection setSectionOffset:(startOfOpeningTag - _dataStart)];
    [newFileSection setSectionLength:0];  // will be filled in later

    [_sectionStack addObject:newFileSection];
}

// on entry, _current points to the opening angle bracket of an <a> tag
- (void)_processAnchorTag
{
    // Make sure we're looking at an <a> tag and not some other tag
    // that starts with "a".
    if (!isspace(_current[2]))
    {
        [self _skipPastClosingAngleBracket];
        return;
    }

    // Scan tokens up to and including the closing ">".  On the way,
    // look for the "name" attribute.
    while (([self parseToken]))
    {
        if (strcmp(_token, ">") == 0)
        {
            break;
        }
        else if (strcmp(_token, "name") == 0) // [agl] case-sensitive
        {
            // Skip the "=" sign.
            (void)[self parseToken];
            if (strcmp(_token, "=") != 0)
            {
                // The token "name" must be in this tag in some way
                // other than being an attribute.
                continue;
            }

            // Skip the opening quote.
            // [agl] add an assert making sure it's a quote
            (void)[self parseToken];

            // The sequence of characters from here to the closing quote
            // is the anchor string.
            const char *anchorStart = _current;

            while ((_current < _dataEnd) && (_current[0] != '\"'))
            {
                _current++;
            }

            NSString *anchorString = [[NSString alloc] initWithBytes:anchorStart
                                                              length:(_current - anchorStart)
                                                            encoding:NSUTF8StringEncoding];

            [[_targetFramework owningDatabase] rememberOffset:(anchorStart - _dataStart)
                                               ofAnchorString:anchorString
                                                   inHTMLFile:[self currentPath]];
        }
    }
}

// Assume we're sitting on an opening angle bracket.
- (void)_skipPastClosingAngleBracket
{
    while (_current < _dataEnd)
    {
        if (_current[0] == '>')
        {
            _current++;
            return;
        }
        else
        {
            _current++;
        }
    }
}

// Assume we're sitting on an <h#>...title...</h#>, where # = headerLevel.
// Extract the title between the <h#> we're sitting on and the next </h#>. 
// Advance _current past the closing </h#>.
//
// Note that there may be other nested tags inside the <h#> element.  If
// we encounter an anchor tag, we process it so we can find it again if
// a link points to it; we ignore other nested tags.
- (NSString *)_parseTitleAtLevel:(char)headerLevel
{
    const char *titleStart;
    NSString *result = nil;

    // Skip past the end of the opening <h#> tag.
    [self _skipPastClosingAngleBracket];

    // Find the beginning of the title.
    while (_current < _dataEnd)
    {
        if (_current[0] == '<')
        {
            if ((_current[1] == 'a') || (_current[1] == 'A'))
            {
                [self _processAnchorTag];
            }
			// JJ Start
			else if ((_current[1] == '/') && ((_current[2] == 'h') || (_current[2] == 'H')))
			{
				break; // This should only occur if title is empty, i.e., <h#></h#>
			}
			// JJ End
            else
            {
                [self _skipPastClosingAngleBracket];
            }
        }
        else if (isspace(_current[0]))
        {
            _current++;
        }
        else
        {
            break;
        }
    }
    titleStart = _current;

    // Find the end of the title, which is assumed to be the beginning of
    // the next tag.
    // [agl] but what if there are <b> tags or something within the title?
    while (_current < _dataEnd)
    {
        if (_current[0] == '<')
        {
            break;
        }
        _current++;
    }

    // Extract the title string.  In the process, convert all whitespace to
    // spaces, and trim leading and trailing whitespace.  For a minor
    // efficiency gain, do these operations on the C string before
    // converting to an NSString (thus avoiding, for example, a call to
    // ak_trimWhitespace).
    NSInteger titleLength = _current - titleStart;
    char titleBuf[titleLength + 1];
    strncpy(titleBuf, titleStart, titleLength);
    titleBuf[titleLength] = '\0';
    char *cp;
    char *trimmedTitleStart = NULL;
    char *trimmedTitleEnd = NULL;
    for (cp = titleBuf; *cp; cp++)
    {
        if (isspace(*cp))
        {
            *cp = ' ';
        }
        else
        {
            if (!trimmedTitleStart)
            {
                trimmedTitleStart = cp;
            }
            trimmedTitleEnd = cp;
        }
    }

    if (trimmedTitleStart)
    {
        result = [[NSString alloc] initWithBytes:titleBuf
                                          length:(trimmedTitleEnd - trimmedTitleStart + 1)
                                        encoding:NSUTF8StringEncoding];
    }
    else
    {
		// JJ Start
		//result = @"untitled section";
		return nil;
		// JJ End
    }

    // Advance past the closing </h#> before returning the title string.
    while (_current < _dataEnd)
    {
        if ((_current[0] == '<') && (_current[1] == '/')
            && ((_current[2] == 'h') || (_current[2] == 'H'))
            && (_current[3] == headerLevel))
        {
            _current += 5; // advance by length of "</h#>"
            return result;
        }
        _current++;
    }

    DIGSLogDebug(@"_parseTitleAtLevel: -- shouldn't have gotten this far");
    return @"???";
}

+ (NSMutableData *)_kludgeDivTagsToH3:(NSData *)sourceData
{
    if (!sourceData)
    {
        DIGSLogWarning(@"_kludgeDivTagsToH3: -- sourceData is nil");
        return nil;
    }

    NSMutableData *newHTMLData = [NSMutableData dataWithCapacity:([sourceData length] + 32)];
    static char *divOpenTag = "<div class=\"mach4\">";
    static char *divCloseTag = "</div>";
    NSInteger divOpenTagLength = strlen(divOpenTag);
    NSInteger divCloseTagLength = strlen(divCloseTag);

    char *endOfLastDivTag = (char *)[sourceData bytes];
    char *startOfDivOpenTag = strstr(endOfLastDivTag, divOpenTag);
    
    while (startOfDivOpenTag)
    {
        // Append the good text we just skipped to the new HTML.
        [newHTMLData appendBytes:endOfLastDivTag
                          length:(startOfDivOpenTag - endOfLastDivTag)];

        // Append an <h3> tag to the new HTML to replace the divOpenTag --
        // but take up exactly as much space as divOpenTag did.
        //                        ...................
        //                        <div class="mach4">
        [newHTMLData appendBytes:"<h3               >" length:divOpenTagLength];

        // Look for the closing tag.
        endOfLastDivTag = startOfDivOpenTag + divOpenTagLength;  // Skip over the divOpenTag.
        char *startOfDivCloseTag = strstr(endOfLastDivTag, divCloseTag);
        if (startOfDivCloseTag)
        {
            // Append the good text we just skipped to the new HTML.
            [newHTMLData appendBytes:endOfLastDivTag
                              length:(startOfDivCloseTag - endOfLastDivTag)];

            // Append "</h3>" to the new HTML to replace the divCloseTag --
            // but take up exactly as much space as divCloseTag did.
            //                        ......
            //                        </div>
            [newHTMLData appendBytes:"</h3 >" length:divCloseTagLength];
            endOfLastDivTag = startOfDivCloseTag + divCloseTagLength;
        }

        // Prepare for next loop iteration by finding the next divOpenTag.
        startOfDivOpenTag = strstr(endOfLastDivTag, divOpenTag);
    }

    // Add the remaining good text.  There will be at least one byte
    // of good text, namely the NULL terminator.
    [newHTMLData appendBytes:endOfLastDivTag
                      length:((char *)[sourceData bytes] + [sourceData length]
                              - endOfLastDivTag)];

    return newHTMLData;
}

+ (NSMutableData *)_kludgeSpanTagsToH1:(NSData *)sourceData
{
    NSMutableData *newHTMLData = [NSMutableData dataWithCapacity:([sourceData length] + 32)];
    static char *spanOpenTag = "<span class=\"page_title\">";
    static char *spanCloseTag = "</span>";
    NSInteger spanOpenTagLength = strlen(spanOpenTag);
    NSInteger spanCloseTagLength = strlen(spanCloseTag);

    char *endOfLastSpanTag = (char *)[sourceData bytes];
    char *startOfSpanOpenTag = strstr(endOfLastSpanTag, spanOpenTag);
    
    while (startOfSpanOpenTag)
    {
        // Append the good text we just skipped to the new HTML.
        [newHTMLData appendBytes:endOfLastSpanTag
                          length:(startOfSpanOpenTag - endOfLastSpanTag)];

        // Append an <h1> tag to the new HTML to replace the spanOpenTag --
        // but take up exactly as much space as spanOpenTag did.
        //                        .........................
        //                        <span class="page_title">
        [newHTMLData appendBytes:"<h1                     >"
                          length:spanOpenTagLength];

        // Look for the closing tag.
        endOfLastSpanTag = startOfSpanOpenTag + spanOpenTagLength;  // Skip over the spanOpenTag.
        char *startOfSpanCloseTag = strstr(endOfLastSpanTag, spanCloseTag);
        if (startOfSpanCloseTag)
        {
            // Append the good text we just skipped to the new HTML.
            [newHTMLData appendBytes:endOfLastSpanTag
                              length:(startOfSpanCloseTag - endOfLastSpanTag)];

            // Append "</h3>" to the new HTML to replace the spanCloseTag --
            // but take up exactly as much space as spanCloseTag did.
            //                        .......
            //                        </span>
            [newHTMLData appendBytes:"</h1  >" length:spanCloseTagLength];
            endOfLastSpanTag = startOfSpanCloseTag + spanCloseTagLength;
        }

        // Prepare for next loop iteration by finding the next spanOpenTag.
        startOfSpanOpenTag = strstr(endOfLastSpanTag, spanOpenTag);
    }

    // Add the remaining good text.  There will be at least one byte
    // of good text, namely the NULL terminator.
    [newHTMLData appendBytes:endOfLastSpanTag
                      length:((char *)[sourceData bytes] + [sourceData length]
                              - endOfLastSpanTag)];

    return newHTMLData;
}

@end
