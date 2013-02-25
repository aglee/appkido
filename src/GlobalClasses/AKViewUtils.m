/*
 * AKViewUtils.m
 *
 * Created by Andy Lee on Sun Aug 03 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKViewUtils.h"

#import "DIGSLog.h"

#pragma mark -
#pragma mark NSView extensions

@implementation NSView (AppKiDo)

- (void)ak_setFrameHeight:(CGFloat)newHeight
{
    NSRect frame = [self frame];

    frame.size.height = newHeight;
    [self setFrame:frame];
}

- (void)ak_printKeyViewLoop
{
    NSView *view = self;
    NSMutableSet *visitedViews = [NSMutableSet set];

    NSLog(@"BEGIN key view sequence:");
    while (YES)
    {
        NSLog(@"  %@ at %p (acceptsFirstResponder = %@)",
              [view className], view, ([view acceptsFirstResponder] ? @"YES" : @"NO"));

        if ([visitedViews containsObject:view])
        {
            NSLog(@"END key view sequence -- sequence contains a loop");
            break;
        }
        [visitedViews addObject:view];

        view = [view nextKeyView];
        if (view == nil)
        {
            NSLog(@"END key view sequence -- reached nil");
            break;
        }
    }
}

- (void)ak_printReverseKeyViewLoop
{
    NSView *view = self;
    NSMutableSet *visitedViews = [NSMutableSet set];

    NSLog(@"BEGIN reverse key view sequence:");
    while (YES)
    {
        NSLog(@"  %@ at %p (acceptsFirstResponder = %@)",
              [view className], view, ([view acceptsFirstResponder] ? @"YES" : @"NO"));

        if ([visitedViews containsObject:view])
        {
            NSLog(@"END key view sequence -- sequence contains a loop");
            break;
        }
        [visitedViews addObject:view];

        view = [view previousKeyView];
        if (view == nil)
        {
            NSLog(@"END key view sequence -- reached nil");
            break;
        }
    }
}

- (void)ak_removeAllElasticity
{
    if ([self isKindOfClass:[NSScrollView class]])
    {
        [(NSScrollView *)self setHorizontalScrollElasticity:NSScrollElasticityNone];
        [(NSScrollView *)self setVerticalScrollElasticity:NSScrollElasticityNone];
    }

    for (NSView *subview in [self subviews])
    {
        [subview ak_removeAllElasticity];
    }
}

@end

#pragma mark -
#pragma mark NSSplitView extensions

@implementation NSSplitView (AppKiDo)

- (void)ak_setHeight:(CGFloat)newHeight ofSubview:(NSView *)subview
{
    if ((newHeight < 0) || (subview == nil))
    {
        return;
    }

    NSArray *subviews = [self subviews];

    if ([subviews count] != 2)
    {
        DIGSLogError_ExitingMethodPrematurely(@"expected splitview to have exactly two subviews");
        return;
    }

    NSView *otherSubview = [self ak_siblingOfSubview:subview];
    CGFloat otherNewHeight = [self frame].size.height - [self dividerThickness] - newHeight;

    [subview ak_setFrameHeight:newHeight];
    [otherSubview ak_setFrameHeight:otherNewHeight];

    [self adjustSubviews];
    [self setNeedsDisplay:YES];
}

- (NSView *)ak_siblingOfSubview:(NSView *)subview
{
    if (subview == nil)
    {
        return nil;
    }

    NSArray *subviews = [self subviews];

    if ([subviews count] != 2)
    {
        DIGSLogError_ExitingMethodPrematurely(@"expected splitview to have exactly two subviews");
        return nil;
    }

    if ([subviews objectAtIndex:0] == subview)
    {
        return [subviews objectAtIndex:1];
    }
    else if ([subviews objectAtIndex:1] == subview)
    {
        return [subviews objectAtIndex:0];
    }
    else
    {
        DIGSLogError_ExitingMethodPrematurely(@"the given view is not a subview of this splitview");
        return nil;
    }
}

@end
