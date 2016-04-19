/*
 * NSMutableAttributedString+AppKiDo.m
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "NSMutableAttributedString+AppKiDo.h"

@implementation NSMutableAttributedString (AppKiDo)

// Thanks to Mike Morton for code this method is based on.
- (void)ak_magnifyUsingMultiplier:(float)multiplier
{
    NSRange selectedRange;
    NSUInteger charIndex;

    selectedRange = NSMakeRange(0, [self length]);
    charIndex = 0;
    do
    {
        NSDictionary *attributes;
        NSRange foundRange;
        NSFont *foundFont;
        NSMutableDictionary *newAttributes;

        attributes = [self attributesAtIndex:charIndex
                       longestEffectiveRange:&foundRange
                                     inRange:selectedRange];
        foundFont = [attributes objectForKey:NSFontAttributeName];

        if (foundFont != nil) // [agl] FIXME-PURISM: can this equal nil?
        {
            float newSize;

            // Get the current size and calculate the new size.
            newSize = [foundFont pointSize] * multiplier;

            //  Get a font of that size, and stick it in
            foundFont = [[NSFontManager sharedFontManager] convertFont:foundFont toSize:newSize];
            newAttributes = [attributes mutableCopy];
            [newAttributes setObject:foundFont forKey:NSFontAttributeName];
            [self setAttributes:newAttributes range:foundRange];
        }

        charIndex = NSMaxRange (foundRange);
    } while (charIndex < NSMaxRange(selectedRange));

    // [agl] FIXME-PURISM: needed?
    [self fixFontAttributeInRange:selectedRange];
}

- (void)ak_magnifyUsingPercentMultiplier:(int)percent
{
    [self ak_magnifyUsingMultiplier:(((float)percent) / 100.0)];
}

@end
