/*
 * NSMutableAttributedString+AppKiDo.h
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@interface NSMutableAttributedString (AppKiDo)

/*!
 * Modifies the size of the receiver's text by a factor of magFactor. A value of
 * 1.0 leaves the string unchanged.
 */
- (void)ak_magnifyUsingMultiplier:(float)multiplier;

/*!
 * Modifies the size of the receiver's text by a factor of magPercent percent. A
 * value of 100 leaves the string unchanged.
 */
- (void)ak_magnifyUsingPercentMultiplier:(int)magPercent;  // [agl] why'd I make magPercent an int?

@end
