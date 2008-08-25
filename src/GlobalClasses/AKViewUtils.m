/*
 * AKViewUtils.m
 *
 * Created by Andy Lee on Sun Aug 03 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKViewUtils.h"

#import "DIGSLog.h"


//-------------------------------------------------------------------------
// NSView extensions
//-------------------------------------------------------------------------

@implementation NSView (AppKiDo)

- (void)ak_setFrameHeight:(float)newHeight
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
        NSLog(
            @"  %@ at 0x%x (acceptsFirstResponder = %@)",
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
        NSLog(
            @"  %@ at 0x%x (acceptsFirstResponder = %@)",
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

@end


//-------------------------------------------------------------------------
// NSSplitView extensions
//-------------------------------------------------------------------------

@implementation NSSplitView (AppKiDo)

- (void)ak_setHeight:(float)newHeight ofSubview:(NSView *)subview
{
    if ((newHeight < 0) || (subview == nil))
    {
        return;
    }

    NSArray *subviews = [self subviews];

    if ([subviews count] != 2)
    {
        DIGSLogExitingMethodPrematurely(
            @"expected splitview to have exactly two subviews");
        return;
    }

    NSView *otherSubview = [self ak_siblingOfSubview:subview];
    float otherNewHeight =
        [self frame].size.height - [self dividerThickness] - newHeight;

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
        DIGSLogExitingMethodPrematurely(
            @"expected splitview to have exactly two subviews");
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
        DIGSLogExitingMethodPrematurely(
            @"the given view is not a subview of this splitview");
        return nil;
    }
}

@end
