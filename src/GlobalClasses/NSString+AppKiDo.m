/*
 * NSString+AppKiDo.m
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "NSString+AppKiDo.h"

@implementation NSString (AppKiDo)

- (BOOL)ak_contains:(NSString *)searchString
{
    NSRange r = [self rangeOfString:searchString];

    return (r.location != NSNotFound);
}

- (BOOL)ak_containsCaseInsensitive:(NSString *)searchString
{
    NSRange r = [self rangeOfString:searchString options:NSCaseInsensitiveSearch];

    return (r.location != NSNotFound);
}

- (NSInteger)ak_positionOf:(NSString *)searchString
{
    NSRange r = [self rangeOfString:searchString];

    if (r.location == NSNotFound)
    {
        return -1;
    }
    else
    {
        return r.location;
    }
}

- (NSInteger)ak_positionAfter:(NSString *)searchString
{
    NSRange r = [self rangeOfString:searchString];

    if (r.location == NSNotFound)
    {
        return -1;
    }
    else
    {
        return r.location + [searchString length];
    }
}

- (NSRange)ak_findString:(NSString *)string
           selectedRange:(NSRange)selectedRange
                 options:(NSUInteger)options
                    wrap:(BOOL)wrap
{
    BOOL forwards = ((options & NSBackwardsSearch) == 0);
    NSUInteger length = [self length];
    NSRange searchRange, range;

    if (forwards)
    {
        searchRange.location = NSMaxRange(selectedRange);
        searchRange.length = length - searchRange.location;
        range = [self rangeOfString:string
                            options:options
                              range:searchRange];

        if ((range.length == 0) && wrap)
        {
            // If not found look at the first part of the string.
            searchRange.location = 0;
            searchRange.length = selectedRange.location;
            range = [self rangeOfString:string
                                options:options
                                  range:searchRange];
        }
    }
    else
    {
        searchRange.location = 0;
        searchRange.length = selectedRange.location;
        range =
        [self rangeOfString:string options:options range:searchRange];
        if ((range.length == 0) && wrap)
        {
            searchRange.location = NSMaxRange(selectedRange);
            searchRange.length = length - searchRange.location;
            range = [self rangeOfString:string
                                options:options
                                  range:searchRange];
        }
    }

    return range;
}        

// [agl] Should simplify the implementation to call stringByTrimmingCharactersInSet:.
// Didn't do so before because that method was not available in 10.1.x.
- (NSString *)ak_trimWhitespace
{
    NSCharacterSet *whitespaceChars = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSInteger originalLength = [self length];
    NSInteger startIndex = 0;
    NSInteger endIndex = startIndex + originalLength - 1;

    while (startIndex < originalLength)
    {
        unichar c = [self characterAtIndex:startIndex];

        if ([whitespaceChars characterIsMember:c])
        {
            startIndex++;
        }
        else
        {
            break;
        }
    }

    while (endIndex > startIndex)
    {
        unichar c = [self characterAtIndex:endIndex];

        if ([whitespaceChars characterIsMember:c])
        {
            endIndex--;
        }
        else
        {
            break;
        }
    }

    NSInteger newLength = endIndex - startIndex + 1;

    if (newLength == originalLength)
    {
        return self;
    }
    else if (endIndex < startIndex)
    {
        return @"";
    }
    else
    {
        NSRange range = NSMakeRange(startIndex, newLength);

        return [self substringWithRange:range];
    }
}

- (NSString *)ak_stripHTML
{
    // The HTML fragment won't have the UTF8 specifier that's at the top of
    // the HTML file, so use an options dictionary to force UTF8.
    NSData *stringData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *stringOptions = @{ NSCharacterEncodingDocumentOption: @(NSUTF8StringEncoding) };
    NSAttributedString *richTextString = [[[NSAttributedString alloc] initWithHTML:stringData
                                                                           options:stringOptions
                                                                documentAttributes:NULL] autorelease];

    return [richTextString string];
}

- (NSString *)ak_firstWord
{
    NSArray *words = [[self ak_trimWhitespace] componentsSeparatedByString:@" "];

    if ([words count])
    {
        return [words objectAtIndex:0];
    }
    else
    {
        return nil;
    }
}

@end
