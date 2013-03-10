/*
 * NSView+AppKiDo.h
 *
 * Created by Andy Lee on Sun Aug 03 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@interface NSView (AppKiDo)

/*! Sets the nextKeyView of each view in the array. */
+ (void)ak_connectViewsIntoKeyViewLoop:(NSArray *)viewsToConnect;

/*! Wrapper around -setFrame:. */
- (void)ak_setFrameWidth:(CGFloat)newWidth;

/*! Wrapper around -setFrame:. */
- (void)ak_setFrameHeight:(CGFloat)newHeight;

/*! Returns either self, an enclosing view, or nil. */
- (id)ak_enclosingViewOfClass:(Class)viewClass;

/*!
 * Sets elasticity to NSScrollElasticityNone in both directions for all scroll
 * views in self's view hierarchy, including self.
 */
- (void)ak_removeAllElasticity;

@end
