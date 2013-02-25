/*
 * AKViewUtils.h
 *
 * Created by Andy Lee on Sun Aug 03 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

#pragma mark -
#pragma mark NSView extensions

@interface NSView (AppKiDo)

/*! Wrapper around -setFrame:. */
- (void)ak_setFrameHeight:(CGFloat)newHeight;

/*!
 * Uses NSLog to print the sequence of next key views starting at self and
 * ending when we either hit nil or detect a loop.
 */
- (void)ak_printKeyViewLoop;

/*!
 * Like ak_printKeyViewLoop, except traverses the loop using previewKeyView
 * instead of nextKeyView.
 */
- (void)ak_printReverseKeyViewLoop;

/*!
 * Sets elasticity to NSScrollElasticityNone in both directions for all scroll
 * views in self's view hierarchy, including self.
 */
- (void)ak_removeAllElasticity;

@end

#pragma mark -
#pragma mark NSSplitView extensions

@interface NSSplitView (AppKiDo)

/*! Requires subview to be one of exactly two subviews of the splitview. */
- (void)ak_setHeight:(CGFloat)newHeight ofSubview:(NSView *)subview;

- (NSView *)ak_siblingOfSubview:(NSView *)subview;

@end
