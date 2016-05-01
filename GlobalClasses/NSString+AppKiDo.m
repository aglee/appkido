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
        return r.location + searchString.length;
    }
}

- (NSRange)ak_findString:(NSString *)string
           selectedRange:(NSRange)selectedRange
                 options:(NSUInteger)options
                    wrap:(BOOL)wrap
{
    BOOL forwards = ((options & NSBackwardsSearch) == 0);
    NSUInteger length = self.length;
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

- (NSString *)ak_trimWhitespace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)ak_stripHTML
{
    if (self.length == 0)
    {
        return @"";
    }

    NSString *xmlString = [NSString stringWithFormat:@"<foo>%@</foo>", self];
    NSError *xmlError = nil;
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithXMLString:xmlString
                                                              options:0
                                                                error:&xmlError];
    if (xmlDoc == nil)
    {
        DIGSLogError(@"Error str%@", xmlError);
    }
    
    return [xmlDoc rootElement].stringValue;
}

- (NSString *)ak_firstWord
{
    NSArray *words = [[self ak_trimWhitespace] componentsSeparatedByString:@" "];

    if (words.count)
    {
        return words[0];
    }
    else
    {
        return nil;
    }
}

@end
