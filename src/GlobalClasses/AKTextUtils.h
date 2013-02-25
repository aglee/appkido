/*
 * AKTextUtils.h
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

#pragma mark -
#pragma mark C string utilities

/*! Creates a new buffer containing a copy of s.  Does a malloc and a strcpy. */
extern char *ak_copystr(const char *s);

#pragma mark -
#pragma mark NSString extensions

@interface NSString (AppKiDo)

/*! Does a case-sensitive substring search. */
- (BOOL)ak_contains:(NSString *)searchString;

/*! Does a case-insensitive substring search. */
- (BOOL)ak_containsCaseInsensitive:(NSString *)searchString;

/*!
 * @method      ak_positionOf:
 * @discussion  Does a case-sensitive substring search, and returns the
 *              position of the found string, or -1 if the string
 *              is not found.  [agl] Or should I return NSNotFound?
 */
- (NSInteger)ak_positionOf:(NSString *)searchString;

/*!
 * @method      ak_positionAfter:
 * @discussion  Does a case-sensitive substring search, and returns the
 *              position after the found string, or -1 if the string
 *              is not found.  [agl] Or should I return NSNotFound?
 */
- (NSInteger)ak_positionAfter:(NSString *)searchString;

/*!
 * @method      ak_findString:selectedRange:options:wrap:
 * @discussion  Does a substring search using the parameters given by
 *              mask and wrapFlag.
 */
- (NSRange)ak_findString:(NSString *)string
           selectedRange:(NSRange)selectedRange
                 options:(NSUInteger)mask
                    wrap:(BOOL)wrapFlag;

/*!
 * @method      ak_trimWhitespace
 * @discussion  Removes whitespace from the beginning and end of the
 *              receiver.
 *
 *              Does the same as -stringByTrimmingCharactersInSet:, which
 *              is not available in 10.1.x.
 */
- (NSString *)ak_trimWhitespace;

/*!
 * @method      ak_stripHTML
 * @discussion  Converts a string containing HTML code into a plain-text
 *              string, by stripping HTML tags and converting entities
 *              to their character equivalents.
 */
- (NSString *)ak_stripHTML;

/*!
 * @method      ak_firstWord
 * @discussion  Extracts the first word in the string, assuming words are
 *              separated by spaces.  Ignores leading and trailing whitespace
 *              in the receiver.
 */
- (NSString *)ak_firstWord;

@end



#pragma mark -
#pragma mark NSMutableAttributedString extensions

@interface NSMutableAttributedString (AppKiDo)

/*!
 * @method      ak_magnifyUsingMultiplier:
 * @discussion  Modifies an attributed string by changing the size of its
 *              text by a factor of magFactor.
 * @param       str
 *                  The string to modify.
 * @param       magFactor
 *                  The magnification multiplier to use.  A value of 1.0
 *                  leaves the string unchanged.
 */
- (void)ak_magnifyUsingMultiplier:(float)multiplier;

/*!
 * @method      ak_magnifyUsingPercentMultiplier:
 * @discussion  Modifies an attributed string by changing the size of its
 *              text by a factor of magPercent percent.
 * @param       str
 *                  The string to modify.
 * @param       magPercent
 *                  The magnification multiplier to use, expressed as a
 *                  percentage.  A value of 100 leaves the string
 *                  unchanged.
 */
- (void)ak_magnifyUsingPercentMultiplier:(int)magPercent;

@end
