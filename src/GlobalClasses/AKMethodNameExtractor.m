//
//  AKMethodNameExtractor.m
//  SelectorExtracter
//
//  Created by Andy Lee on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AKMethodNameExtractor.h"
#import <ctype.h>


@interface AKMethodNameExtractor ()
{
@private
	char *_start;
	char *_current;
}
@end


@implementation AKMethodNameExtractor

- (id)initWithString:(NSString *)string
{
	self = [super init];
	if (self)
	{
		const char *origChars = [string UTF8String];
		int numChars = strlen(origChars);
		
		_start = malloc(numChars + 1);
		(void)strncpy(_start, origChars, numChars);
		_start[numChars] = '\0';
		
		_current = _start;
	}
	
	return self;
}

- (void)dealloc
{
	free(_start);
	
	[super dealloc];
}

+ (NSString *)extractMethodNameFromString:(NSString *)string
{
    AKMethodNameExtractor *me = [[[self alloc] initWithString:string] autorelease];
    
    return [me extractMethodName];
}

- (NSString *)extractMethodName
{
	NSMutableString *methodName = [NSMutableString string];
	NSString *lastTopLevelElement = nil;
	
	// Skip prelude.
	[self _scanWhitespace];
	
	if (*_current == '+' || *_current == '-')
	{
		_current++;
		[self _scanWhitespace];
	}
	
	if (*_current == '(')
	{
		[self _scanPastClosingDelimiter];
		[self _scanWhitespace];
	}
	
	if (*_current == '[')
	{
		_current++;
	}
	
	// Now we should have either a "naked" message send (with square brackets removed)
	// or a method declaration minus the return type.
	while (*_current)
	{
		[self _scanWhitespace];
		
		if (!*_current)
		{
			break;
		}
		
		char *elementStart = _current;
		{{
			[self _scanElement];
		}}
		char *elementEnd = _current;
		
		lastTopLevelElement = [[[NSString alloc] initWithBytes:elementStart
														length:(elementEnd - elementStart)
													  encoding:NSUTF8StringEncoding]
							   autorelease];
		
		if ([lastTopLevelElement hasSuffix:@":"])
		{
			// Note this accepts malformed method name components. Not worrying about it.
			[methodName appendString:lastTopLevelElement];
		}
	}
	
	// At this point methodName only contains a method name if keyword method components
	// were found. But the method might be a unary method.
	if ([methodName length] == 0 && [self _isValidUnaryMethodName:lastTopLevelElement])
	{
		[methodName appendString:lastTopLevelElement];
	}
	
	return ([methodName length] ? methodName : nil);
}

#pragma mark - Private methods

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

- (void)_scanWhitespace
{
	while (isspace(*_current))
	{
		_current++;
	}
}

// Assumes we are on a non-whitespace character that begins an element.
- (void)_scanElement
{
	if (!*_current)
	{
		return;
	}
	
	char ch = *_current;
	
	// If we prematurely encounter a closing delimiter, skip the rest of the string.
	if (ch == ')' || ch == ']' || ch == '}')
	{
		while (*_current)
		{
			_current++;
		}
		return;
	}
	
	// See if we're on an element that has delimiting punctuation like (), [], or {}.
	if (ch == '(' || ch == '[' || ch == '{')
	{
		[self _scanPastClosingDelimiter];
		return;
	}
	
	// See if we're at the beginning of a string.
	if (ch == '\'' || ch == '"')
	{
		[self _scanQuotedString];
		return;
	}
	
	// See if we're at the beginning of a comment.
	if (ch == '/')
	{
		[self _maybeScanComment];
	}
	
	// There's some punctuation that we should treat as single-character "words".
	if (ch == '@' || ch == '*' || ch == '^' || ch == ',')
	{
		_current++;
		return;
	}
	
	[self _scanWord];
}

// Assumes we are on a '/' character that *might* be the beginning of a comment
// (either /* or //).
- (void)_maybeScanComment
{
	_current++;  // Skip the slash.
	
	if (*_current == '/')
	{
		_current++;
		[self _scanPastEndOfLine];
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

- (void)_scanPastEndOfLine
{
	for ( ; *_current; _current++)
	{
		if (*_current == '\r')
		{
			_current++;
			break;
		}
		else if (*_current == '\r')
		{
			_current++;
			
			if (*_current == 'n')
			{
				_current++;
			}
			
			break;
		}
	}
}

// Assumes we're on the first character of the word. For our purposes, a "word"
// can include [agl] finish this comment
- (void)_scanWord
{
	for ( ; *_current; _current++)
	{
		char ch = *_current;
		
		// Characters that indicate we've passed end of word.
		if (// Whitespace
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
		
		// Character that ends of a method fragment.
		if (ch == ':')
		{
			_current++;  // The ':' is part of the method fragment.
			break;
		}
	}
}

// Assumes we're on the opening delimiter.
- (void)_scanPastClosingDelimiter
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
	
	// Skip all elements until we land on the closing delimiter.
	while (*_current)
	{
		[self _scanWhitespace];
		
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
		
		[self _scanElement];
	}
}

// Assumes we're on the opening delimiter.
- (void)_scanQuotedString
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
