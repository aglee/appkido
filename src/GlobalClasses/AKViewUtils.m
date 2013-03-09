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

+ (void)ak_connectViewsIntoKeyViewLoop:(NSArray *)viewsToConnect
{
    NSView *previousView = [viewsToConnect lastObject];
    
    for (NSView *view in viewsToConnect)
    {
        [previousView setNextKeyView:view];
        previousView = view;
    }
}

- (void)ak_setFrameWidth:(CGFloat)newWidth
{
    NSRect frame = [self frame];

    frame.size.width = newWidth;
    [self setFrame:frame];
}

- (void)ak_setFrameHeight:(CGFloat)newHeight
{
    NSRect frame = [self frame];

    frame.size.height = newHeight;
    [self setFrame:frame];
}

- (id)ak_enclosingViewOfClass:(Class)viewClass
{
    for (NSView *view = self; view != nil; view = [view superview])
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

- (NSArray *)ak_arrayWithObject:(id)obj count:(NSInteger)count  // [agl] Could be a public utility method.
{
    NSMutableArray *numbersOut = [NSMutableArray array];

    for (NSInteger n = 0; n < count; n++)
    {
        [numbersOut addObject:obj];
    }

    return numbersOut;
}

// Expecting non-negative numbers, but this is not checked. Returns integers.
- (NSArray *)ak_scaleDistances:(NSArray *)numbersIn  // [agl] Could be a public utility method.
         toIntegersThatAddUpTo:(NSInteger)desiredTotal
{
    // If empty in, then empty out.
    NSInteger count = [numbersIn count];
    if (count == 0)
    {
        return @[];
    }

    // Only zero distances add up to zero.
    if (desiredTotal == 0)
    {
        return [self ak_arrayWithObject:@0 count:count];
    }

    // Calculate multiplier.
    CGFloat oldTotal = 0;

    for (NSNumber *num in numbersIn)
    {
        oldTotal += [num floatValue];
    }

    if (oldTotal == 0)
    {
        return [self ak_arrayWithObject:@0 count:count];
    }

    CGFloat multiplier = ((float)desiredTotal) / oldTotal;

    // Scale each element of the original list.
    NSMutableArray *numbersOut = [NSMutableArray array];
    NSNumber *lastNumberIn = [numbersIn lastObject];
    NSInteger remaining = desiredTotal;

    for (NSNumber *num in numbersIn)
    {
        if (num != lastNumberIn)
        {
            NSInteger outNumber = multiplier * [num floatValue];
            
            [numbersOut addObject:@(outNumber)];
            remaining -= outNumber;
        }
        else
        {
            // Special-case the last number to avoid rounding error. This
            // ensures that the numbers add up.
            [numbersOut addObject:@(remaining)];
        }
    }

    return numbersOut;
}

enum
{
    AKHorizontalDirection,
    AKVerticalDirection
};

static CGFloat AKRectEdgeAmount(NSRect rect, int whichDirection)  // [agl] These could be public utilities.
{
    return (whichDirection == AKHorizontalDirection
            ? rect.size.width
            : rect.size.height);
}

static void AKSetRectEdgeAmount(NSRect *rectPtr, int whichDirection, CGFloat newAmount)
{
    if (whichDirection == AKHorizontalDirection)
    {
        (*rectPtr).size.width = newAmount;
    }
    else
    {
        (*rectPtr).size.height = newAmount;
    }
}

//static CGFloat AKRectOriginCoord(NSRect rect, int whichDirection)
//{
//    return (whichDirection == AKHorizontalDirection
//            ? rect.origin.x
//            : rect.origin.y);
//}

static void AKSetRectOriginCoord(NSRect *rectPtr, int whichDirection, CGFloat newCoord)
{
    if (whichDirection == AKHorizontalDirection)
    {
        (*rectPtr).origin.x = newCoord;
    }
    else
    {
        (*rectPtr).origin.y = newCoord;
    }
}

static CGFloat AKOtherDirection(int whichDirection)
{
    return (whichDirection == AKHorizontalDirection
            ? AKVerticalDirection
            : AKHorizontalDirection);
}

// "Edge amount" is my placeholder for either "width" or "height", depending on
// the value of whichDirection.
- (void)ak_setEdgeAmount:(NSInteger)fixedEdgeAmount
               direction:(int)whichDirection
        ofSubviewAtIndex:(NSInteger)chosenSubviewIndex
{
    if (fixedEdgeAmount < 0)
    {
        return;  // [agl] log
    }

    NSInteger numSubviews = [[self subviews] count];
    
    if ((chosenSubviewIndex < 0) || (chosenSubviewIndex >= numSubviews))
    {
        return;  // [agl] log
    }

    // Collect the old edge amounts of the other subviews into an array.
    NSView *chosenSubview = [[self subviews] objectAtIndex:chosenSubviewIndex];
    CGFloat oldTotalOfOtherEdgeAmounts = 0;
    NSMutableArray *oldOtherEdgeAmounts = [NSMutableArray array];

    for (NSView *subview in [self subviews])
    {
        if (subview != chosenSubview)
        {
            CGFloat subviewEdgeAmount = AKRectEdgeAmount([subview frame], whichDirection);
            
            oldTotalOfOtherEdgeAmounts += subviewEdgeAmount;
            [oldOtherEdgeAmounts addObject:@(subviewEdgeAmount)];
        }
    }

    // Calculate the new edge amounts by scaling the old edge amounts.
    CGFloat divider = [self dividerThickness];
    CGFloat selfEdgeAmount = AKRectEdgeAmount([self frame], whichDirection);
    CGFloat newTotalOfOtherEdgeAmounts = (selfEdgeAmount
                                          - fixedEdgeAmount
                                          - (numSubviews - 1) * divider);
    NSArray *newOtherEdgeAmounts = [self ak_scaleDistances:oldOtherEdgeAmounts
                                     toIntegersThatAddUpTo:newTotalOfOtherEdgeAmounts];

    // Apply the new edge amounts to all subviews.
    CGFloat subviewOriginCoord = 0;
    NSInteger otherEdgeAmountsIndex = 0;
    for (NSView *subview in [self subviews])
    {
        NSRect subviewFrame = [subview frame];
        int otherDirection = AKOtherDirection(whichDirection);

        AKSetRectOriginCoord(&subviewFrame, whichDirection, subviewOriginCoord);
        AKSetRectOriginCoord(&subviewFrame, otherDirection, 0);
        AKSetRectEdgeAmount(&subviewFrame,
                            otherDirection,
                            AKRectEdgeAmount([self bounds], otherDirection));

        if (subview == chosenSubview)
        {
            AKSetRectEdgeAmount(&subviewFrame, whichDirection, fixedEdgeAmount);
        }
        else
        {
            CGFloat otherEdgeAmount = [[newOtherEdgeAmounts objectAtIndex:otherEdgeAmountsIndex] floatValue];
            AKSetRectEdgeAmount(&subviewFrame, whichDirection, otherEdgeAmount);
            otherEdgeAmountsIndex++;
        }

        [subview setFrame:subviewFrame];
        subviewOriginCoord += AKRectEdgeAmount(subviewFrame, whichDirection) + divider;
    }
    
    [self setNeedsDisplay:YES];
}

- (void)ak_setWidth:(NSInteger)fixedWidth ofSubviewAtIndex:(NSInteger)subviewIndex
{
    [self ak_setEdgeAmount:fixedWidth
                 direction:AKHorizontalDirection
          ofSubviewAtIndex:subviewIndex];
}

- (void)ak_preserveWidthOfSubviewAtIndex:(NSInteger)subviewIndex
{
    CGFloat fixedWidth = [[[self subviews] objectAtIndex:subviewIndex] frame].size.width;
    
    [self ak_setEdgeAmount:fixedWidth
                 direction:AKHorizontalDirection
          ofSubviewAtIndex:subviewIndex];
}

- (void)ak_setHeight:(NSInteger)fixedHeight ofSubviewAtIndex:(NSInteger)subviewIndex
{
    [self ak_setEdgeAmount:fixedHeight
                 direction:AKVerticalDirection
          ofSubviewAtIndex:subviewIndex];
}

- (void)ak_preserveHeightOfSubviewAtIndex:(NSInteger)subviewIndex
{
    CGFloat fixedHeight = [[[self subviews] objectAtIndex:subviewIndex] frame].size.height;

    [self ak_setEdgeAmount:fixedHeight
                 direction:AKVerticalDirection
          ofSubviewAtIndex:subviewIndex];
}

@end
