/*
 * AKTextUtils.m
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTextUtils.h"

// This import picks up AppKit extensions to Foundation string classes.
#import <AppKit/AppKit.h>


//-------------------------------------------------------------------------
// C string utilities
//-------------------------------------------------------------------------

extern char *ak_copystr(const char *s)
{
    char *copy = (char *)malloc(strlen(s) + 1);
    strcpy(copy, s);
    return copy;
}

//-------------------------------------------------------------------------
// NSString extensions
//-------------------------------------------------------------------------

@implementation NSString (AppKiDo)

- (BOOL)ak_contains:(NSString *)searchString
{
    NSRange r = [self rangeOfString:searchString];

    return (r.location != NSNotFound);
}

- (BOOL)ak_containsCaseInsensitive:(NSString *)searchString
{
    NSRange r =
        [self rangeOfString:searchString options:NSCaseInsensitiveSearch];

    return (r.location != NSNotFound);
}

- (int)ak_positionOf:(NSString *)searchString
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

- (int)ak_positionAfter:(NSString *)searchString
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
    options:(unsigned)options
    wrap:(BOOL)wrap
{
    BOOL forwards = ((options & NSBackwardsSearch) == 0);
    unsigned length = [self length];
    NSRange searchRange, range;

    if (forwards)
    {
        searchRange.location = NSMaxRange(selectedRange);
        searchRange.length = length - searchRange.location;
        range =
            [self
                rangeOfString:string
                options:options
                range:searchRange];

        if ((range.length == 0) && wrap)
        {
            // If not found look at the first part of the string.
            searchRange.location = 0;
            searchRange.length = selectedRange.location;
            range =
                [self
                    rangeOfString:string
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
            range =
                [self
                    rangeOfString:string
                    options:options
                    range:searchRange];
        }
    }

    return range;
}        

- (NSString *)ak_trimWhitespace
{
    NSCharacterSet *whitespaceChars =
        [NSCharacterSet whitespaceAndNewlineCharacterSet];
    int originalLength = [self length];
    int startIndex = 0;
    int endIndex = startIndex + originalLength - 1;

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

    int newLength = endIndex - startIndex + 1;

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
    NSDictionary *stringOptions =
        [NSDictionary
            dictionaryWithObject:[NSNumber numberWithInt:NSUTF8StringEncoding]
            forKey:NSCharacterEncodingDocumentOption];
    NSAttributedString *richTextString =
        [[[NSAttributedString alloc]
            initWithHTML:stringData
            options:stringOptions
            documentAttributes:(NSDictionary **)NULL] autorelease];

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


/* --- these methods aren't being used at the moment ---

//-------------------------------------------------------------------------
// NSMutableAttributedString extensions
//-------------------------------------------------------------------------

@implementation NSMutableAttributedString (AppKiDo)

// Thanks to Mike Morton for code this method is based on.
- (void)ak_magnifyUsingMultiplier:(float)multiplier
{
    NSRange selectedRange;
    unsigned int index;

    selectedRange = NSMakeRange(0, [self length]);
    index = 0;
    do
    {
        NSDictionary *attributes;
        NSRange foundRange;
        NSFont *foundFont;
        NSMutableDictionary *newAttributes;

        attributes =
            [self attributesAtIndex:index
                longestEffectiveRange:&foundRange
                inRange:selectedRange];
        foundFont = [attributes objectForKey:NSFontAttributeName];

        if (foundFont != nil) // [agl] FIXME-PURISM: can this equal nil?
        {
            float newSize;

            // Get the current size and calculate the new size.
            newSize = [foundFont pointSize] * multiplier;

            //  Get a font of that size, and stick it in
            foundFont =
                [[NSFontManager sharedFontManager]
                    convertFont:foundFont toSize:newSize];
            newAttributes = [[attributes mutableCopy] autorelease];
            [newAttributes setObject:foundFont forKey:NSFontAttributeName];
            [self setAttributes:newAttributes range:foundRange];
        }

        index = NSMaxRange (foundRange);
    } while (index < NSMaxRange(selectedRange));

    // [agl] FIXME-PURISM: needed?  Maybe Mike knows?
    [self fixFontAttributeInRange:selectedRange];
}

- (void)ak_magnifyUsingPercentMultiplier:(int)percent
{
    float multiplier = ((float)percent) / 100.0;

    [self ak_magnifyUsingMultiplier:multiplier];
}

@end

--- */
