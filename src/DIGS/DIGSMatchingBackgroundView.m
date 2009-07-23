/*
 * DIGSMatchingBackgroundView.m
 *
 * Created by Andy Lee on Sun Jan 19 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "DIGSMatchingBackgroundView.h"

@implementation DIGSMatchingBackgroundView


#pragma mark -
#pragma mark NSView methods

- (void)drawRect:(NSRect)aRect
{
    if ([_viewToMatch respondsToSelector:@selector(backgroundColor)])
    {
        // The cast to NSTextView* is to avoid a compiler warning.
        [[(NSTextView *)_viewToMatch backgroundColor] set];
        NSRectFill(aRect);
    }
}

@end
