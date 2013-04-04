//
//  AKMethodNameExtractor.m
//  AppKiDo
//
//  Created by Andy Lee on 7/14/12.
//  Copyright (c) 2012 Andy Lee. All rights reserved.
//

#import "AKMethodNameExtractor.h"
#import <ctype.h>

@implementation AKMethodNameExtractor

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithString:(NSString *)string
{
    self = [super init];
    if (self)
    {
        NSData *asciiData = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        size_t numChars = [asciiData length];

        _buffer = malloc(numChars + 1);
        (void)strncpy(_buffer, [asciiData bytes], numChars);
        _buffer[numChars] = '\0';

        _current = _buffer;
    }

    return self;
}

- (void)dealloc
{
    free(_buffer);

    [super dealloc];
}

#pragma mark -
#pragma mark Parsing

+ (NSString *)extractMethodNameFromString:(NSString *)string
{
    AKMethodNameExtractor *methEx = [[[self alloc] initWithString:string] autorelease];

    return [methEx extractMethodName];
}

- (NSString *)extractMethodName
{
    // Start at the beginning.
    _current = _buffer;

    // Skip prelude.
    //
    // Case 1, message-send: If we have "(SomeTypeCast)[someMessageSend..." then we want
    // to skip the "(SomeTypeCast)[".
    //
    // Case 2, method declaration: If we have "- (SomeReturnType)someInstanceMethod..."
    // then we want to skip the "- (SomeReturnType)". Similarly if it's a class method.
    [self _skipWhitespaceAndComments];

    if (*_current == '+' || *_current == '-')
    {
        _current++;
        [self _skipWhitespace];
    }

    if (*_current == '(')
    {
        [self _skipPastClosingBookend];
        [self _skipWhitespace];
    }

    if (*_current == '[')
    {
        _current++;
    }

    // Iterate over the top-level elements in the remainder of the input string.
    // See the _skipElement comment for what we consider an "element".
    NSMutableString *keywordMethodName = [NSMutableString string];
    NSString *lastSimpleIdentifier = nil;

    while (*_current)
    {
        [self _skipWhitespace];

        if (!*_current)
        {
            break;
        }

        char *elementStart = _current;
        {{
            [self _skipElement];
        }}
        char *elementEnd = _current;

        NSString *element = [[[NSString alloc] initWithBytes:elementStart
                                                      length:(elementEnd - elementStart)
                                                    encoding:NSUTF8StringEncoding] autorelease];
        if ([element hasSuffix:@":"])
        {
            // Assume element is one component of a multipart method name.
            [keywordMethodName appendString:element];
        }
        else if ([self _isValidUnaryMethodName:element])
        {
            // Remember the last simple identifier we came across as a top-level
            // element. If we don't detect a multi-part method name, we will
            // assume this identifier is a unary method name.
            lastSimpleIdentifier = element;
        }
    }

    // Did we extract a multi-part method name?
    if ([keywordMethodName length] == 0)
    {
        return lastSimpleIdentifier;
    }
    else
    {
        return keywordMethodName;
    }
}

#pragma mark -
#pragma mark Private methods

- (BOOL)_isValidUnaryMethodName:(NSString *)string
{
    NSUInteger len = [string length];

    if (len == 0)
    {
        return NO;
    }

    // We know it's a non-empty string. Check the first character.
    NSUInteger pos = 0;
    unichar ch = [string characterAtIndex:pos];

    if (ch != '_' && !isalpha(ch))
    {
        return NO;
    }

    // Check the remaining characters.
    for (pos = 1 ; pos < len; pos++)
    {
        unichar ch = [string characterAtIndex:pos];

        if (ch != '_' && !isalnum(ch))
        {
            return NO;
        }
    }

    // If we got this far, the name is valid.
    return YES;
}

- (void)_skipWhitespaceAndComments
{
    while (1)
    {
        [self _skipWhitespace];

        if (_current[0] == '/'
            && (_current[1] == '/' || _current[1] == '*'))
        {
            [self _maybeScanComment];
        }
        else
        {
            break;
        }
    }
}

- (void)_skipWhitespace
{
    while (isspace(*_current))
    {
        _current++;
    }
}

// Assumes we are on a non-whitespace character that begins an element. Scans to either
// the character after the end of the element, or to the end of the input.
//
// An "element" is one of the following:
//
//  - "Bookended" expression delimited by opening and closing punctuation. We only care
//    about the types that can be nested: (...), [...], {...}. We don't care about
//    expressions like <SomeProtocol>, because they can't be nested.
//  - String literal delimited by either single- or double-quote characters: 'APPL', "hello".
//  - Comment, of either the // or /* type.
//  - One of these characters: '@', '*', '^', ','.
//  - "Word" -- a sequence of non-whitespace characters that don't get parsed as any of the
//    above. A "word" could be something like "abc.xyz->pdq". We aren't trying to be a full
//    C parser here. We don't care about the abc, xyz, or pdq as separate terms, so we treat
//    the whole thing as a word.
//
// When we see a "bookended" expression we don't care what's inside the delimiters. We are
// going to discard the whole expression anyway. But we do care about properly parsing nested
// expressions so that we can properly scan past the correct closing delimiter for a given
// opening delimiter.
//
// Adjacent elements are separated by zero or more whitespace characters. For example, an
// NSString literal looks to this parser like two elements, the @ and the "string",
// separated by zero characters.
- (void)_skipElement
{
    if (!*_current)
    {
        return;
    }

    char ch = *_current;

    // If we prematurely encounter a closing bookend, skip the rest of the string.
    if (ch == ')' || ch == ']' || ch == '}')
    {
        while (*_current)
        {
            _current++;
        }
        return;
    }

    // See if we're on the opening bookend of an element like (...), [...], or {...}.
    if (ch == '(' || ch == '[' || ch == '{')
    {
        [self _skipPastClosingBookend];
        return;
    }

    // See if we're at the beginning of a string literal delimited by either single- or
    // double-quotes.
    if (ch == '\'' || ch == '"')
    {
        [self _skipQuotedString];
        return;
    }

    // See if we're at the beginning of a comment, of either the // or /* kind. If not,
    // we'll skip over the / to the next character.
    if (ch == '/')
    {
        [self _maybeScanComment];
    }

    // There's some punctuation that we treat as single-character "words".
    if (ch == '@' || ch == '*' || ch == '^' || ch == ',')
    {
        _current++;
        return;
    }

    // Any other characters are considered part of a "word".
    [self _skipWord];
}

// Assumes we are on a '/' character that *might* be the beginning of a comment
// (either /* or //). If we're not on a comment, we just skip past the '/'. If we
// *are* on a comment, we skip to the character after the comment.
- (void)_maybeScanComment
{
    _current++;  // Skip the slash.

    if (*_current == '/')
    {
        _current++;
        [self _skipPastEndOfLine];
    }
    else if (*_current == '*')
    {
        _current++;

        // Scan past the */ that closes the comment.
        for ( ; *_current; _current++)
        {
            if (_current[0] == '*' && _current[1] == '/')
            {
                _current += 2;
                break;
            }
        }
    }
}

- (void)_skipPastEndOfLine
{
    for ( ; *_current; _current++)
    {
        if (*_current == '\n')
        {
            _current++;
            break;
        }
        else if (*_current == '\r')
        {
            _current++;

            if (*_current == '\n')
            {
                _current++;
            }

            break;
        }
    }
}

// Assumes we're on the first character of the word.
- (void)_skipWord
{
    for ( ; *_current; _current++)
    {
        char ch = *_current;

        // Characters that indicate we've passed end of word.
        if (
            // Whitespace
            isspace(ch)

            // Delimiters.
            || ch == '(' || ch == ')'
            || ch == '[' || ch == ']'
            || ch == '{' || ch == '}'

            // Single-character "words".
            || ch == '@'
            || ch == '*'
            || ch == '^'
            || ch == ','

            // Possible comment.
            || ch == '/')
        {
            break;
        }

        // Character that ends a keyword in a keyword message.
        if (ch == ':')
        {
            _current++;  // The ':' is part of the keyword, so skip over it.
            break;
        }
    }
}

// Assumes we're on the opening bookend character -- either '(', '[', or '{'.
- (void)_skipPastClosingBookend
{
    // Figure out what the closing delimiter is, based on the opening delimiter.
    char opener = *_current;
    char closer = '\0';

    if (opener == '(')
    {
        closer = ')';
    }
    else if (opener == '[')
    {
        closer = ']';
    }
    else if (opener == '{')
    {
        closer = '}';
    }

    // Skip over the opening delimiter.
    _current++;
    
    // If we don't recognize the opening delimiter, bail.
    if (closer == '\0')
    {
        return;
    }

    // Skip all elements until we land on the closing delimiter.
    while (*_current)
    {
        [self _skipWhitespace];

        if (!*_current)
        {
            // We've hit premature end of input.
            break;
        }

        if (*_current == closer)
        {
            _current++;
            break;
        }

        [self _skipElement];
    }
}

// Assumes we're on the opening quote character.
- (void)_skipQuotedString
{
    char closer = *_current;

    // Skip over the open-quote.
    _current++;

    // Consume characters until we hit the close-quote.
    for ( ; *_current; _current++)
    {
        if (!*_current)
        {
            // We've hit premature end of input.
            break;
        }

        if (*_current == closer)
        {
            _current++;
            break;
        }

        if (*_current == '\\')
        {
            _current++;
        }
    }
}

@end
