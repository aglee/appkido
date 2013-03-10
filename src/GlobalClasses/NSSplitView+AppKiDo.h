/*
 * NSSplitView+AppKiDo.h
 *
 * Created by Andy Lee on Sun Aug 03 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

/*!
 * Methods that can be handy for implementations of
 * splitView:resizeSubviewsWithOldSize:.
 */
@interface NSSplitView (AppKiDo)

- (void)ak_setWidth:(NSInteger)fixedWidth ofSubviewAtIndex:(NSInteger)subviewIndex;
- (void)ak_preserveWidthOfSubviewAtIndex:(NSInteger)subviewIndex;

- (void)ak_setHeight:(NSInteger)fixedHeight ofSubviewAtIndex:(NSInteger)subviewIndex;
- (void)ak_preserveHeightOfSubviewAtIndex:(NSInteger)subviewIndex;

@end
