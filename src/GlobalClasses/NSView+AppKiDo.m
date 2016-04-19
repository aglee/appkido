/*
 * NSView+AppKiDo.m
 *
 * Created by Andy Lee on Sun Aug 03 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "NSView+AppKiDo.h"

@implementation NSView (AppKiDo)

+ (void)ak_connectViewsIntoKeyViewLoop:(NSArray *)viewsToConnect
{
    NSView *previousView = viewsToConnect.lastObject;
    
    for (NSView *view in viewsToConnect)
    {
        previousView.nextKeyView = view;
        previousView = view;
    }
}

- (void)ak_setFrameWidth:(CGFloat)newWidth
{
    NSRect frame = self.frame;

    frame.size.width = newWidth;
    self.frame = frame;
}

- (void)ak_setFrameHeight:(CGFloat)newHeight
{
    NSRect frame = self.frame;

    frame.size.height = newHeight;
    self.frame = frame;
}

- (id)ak_enclosingViewOfClass:(Class)viewClass
{
    for (NSView *view = self; view != nil; view = view.superview)
    {
        if ([view isKindOfClass:viewClass])
        {
            return view;
        }
    }

    return nil;
}

- (void)ak_removeAllElasticity
{
    if ([self isKindOfClass:[NSScrollView class]])
    {
        ((NSScrollView *)self).horizontalScrollElasticity = NSScrollElasticityNone;
        ((NSScrollView *)self).verticalScrollElasticity = NSScrollElasticityNone;
    }

    for (NSView *subview in self.subviews)
    {
        [subview ak_removeAllElasticity];
    }
}

@end
