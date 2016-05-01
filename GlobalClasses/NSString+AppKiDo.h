/*
 * NSString+AppKiDo.h
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

@interface NSString (AppKiDo)

/*! Does a case-sensitive substring search. */
- (BOOL)ak_contains:(NSString *)searchString;

/*! Does a case-insensitive substring search. */
- (BOOL)ak_containsCaseInsensitive:(NSString *)searchString;

/*!
 * Does a case-sensitive substring search. Returns the position of the found
 * string, or -1 if the string is not found.
 */
- (NSInteger)ak_positionOf:(NSString *)searchString;

/*!
 * Does a case-sensitive substring search. Returns the position after the found
 * string, or -1 if the string is not found.
 */
- (NSInteger)ak_positionAfter:(NSString *)searchString;

/*! Does a substring search. */
- (NSRange)ak_findString:(NSString *)string
           selectedRange:(NSRange)selectedRange
                 options:(NSUInteger)mask
                    wrap:(BOOL)wrapFlag;

/*! Removes whitespace from the beginning and end of the receiver. */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *ak_trimWhitespace;

/*!
 * Converts a string containing HTML code into a plain-text string, by stripping
 * HTML tags and converting entities to their character equivalents.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *ak_stripHTML;

/*!
 * Extracts the first word in the receiver, assuming words are separated by
 * spaces. Ignores leading and trailing whitespace in the receiver.
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *ak_firstWord;

@end
