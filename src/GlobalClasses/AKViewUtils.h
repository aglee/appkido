/*
 * AKViewUtils.h
 *
 * Created by Andy Lee on Sun Aug 03 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

/*!
 * @category    NSView(AppKiDo)
 */
@interface NSView (AppKiDo)

/*!
 * @method      ak_setFrameHeight:
 * @discussion  Convenience method that's a wrapper around -setFrame:.
 */
- (void)ak_setFrameHeight:(CGFloat)newHeight;

/*!
 * @method      ak_printKeyViewLoop
 * @discussion  Uses NSLog to print the sequence of next key views starting at
 *              self and ending when we either hit nil or detect a loop.
 */
- (void)ak_printKeyViewLoop;

/*!
 * @method      ak_printReverseKeyViewLoop
 * @discussion  Like ak_printKeyViewLoop, except traverses the loop using
 *              previewKeyView instead of nextKeyView.
 */
- (void)ak_printReverseKeyViewLoop;

/*!
 * @method      ak_removeAllElasticity
 * @discussion  Sets elasticity to NSScrollElasticityNone in both directions for
 *              all scroll views in self's view hierarchy, including self.
 */
- (void)ak_removeAllElasticity;

@end


/*!
 * @category    NSSplitView(AppKiDo)
 */
@interface NSSplitView (AppKiDo)

// requires subview to be one of exactly two subviews of the splitview
- (void)ak_setHeight:(CGFloat)newHeight ofSubview:(NSView *)subview;

- (NSView *)ak_siblingOfSubview:(NSView *)subview;

@end
