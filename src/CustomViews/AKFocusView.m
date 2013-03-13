//
//  AKFocusView.m
//  AppKiDo
//
//  Created by Andy Lee on 3/11/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKFocusView.h"
#import <WebKit/WebKit.h>

@implementation AKFocusView

static const CGFloat AKFocusBorderThickness = 2.0;

#pragma mark -
#pragma mark Init/dealloc/awake

- (void)dealloc
{
    [_owningWindow removeObserver:self forKeyPath:@"firstResponder"];
    _owningWindow = nil;

    [super dealloc];
}

#pragma mark -
#pragma mark Focus ring

//- (void)invalidateFocusIndicator
//{
//    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
//}
//
//- (void)drawFocusIndicator
//{
//    [NSGraphicsContext saveGraphicsState];
//    {{
//        NSSetFocusRingStyle(NSFocusRingOnly);
//
//        // There's a *teeny* difference in colors between using
//        // NSBezierPath and NSFrameRect. I think I prefer the latter.
//        //[[NSBezierPath bezierPathWithRect:focusRingRect] fill];
//        NSFrameRect([[[self subviews] lastObject] frame]);
//    }}
//    [NSGraphicsContext restoreGraphicsState];
//}

- (void)invalidateFocusIndicator
{
    [self setNeedsDisplay:YES];
}

- (void)drawFocusIndicator
{
    NSColor *focusRingColor = ([[self window] isKeyWindow]
                               ? [NSColor keyboardFocusIndicatorColor]
                               : [NSColor darkGrayColor]);
    [focusRingColor set];
    NSFrameRectWithWidth([self bounds], AKFocusBorderThickness);
}

#pragma mark -
#pragma mark NSView methods

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
    // Assume we have exactly one subview.
    NSView *innerView = [[self subviews] lastObject];

    // Inset the inner view slightly within our bounds. This means I don't have
    // to be precise about positioning the inner view in IB, because I know it
    // will be adjusted here.
    [innerView setFrame:NSInsetRect([self bounds], AKFocusBorderThickness, AKFocusBorderThickness)];
    [innerView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

    // Suppress any focus ring that would normally be drawn by the inner view.
    // [agl] Could someday make this conditional; we don't use the built-in
    // focus ring stuff, but a subclass might want to.
    [innerView setFocusRingType:NSFocusRingTypeNone];
    if ([innerView isKindOfClass:[NSScrollView class]])
    {
        [[(NSScrollView *)innerView documentView] setFocusRingType:NSFocusRingTypeNone];
    }
}

- (void)viewDidMoveToWindow
{
    // We want to know when our owning window changes first responder, so we can
    // redraw our focus indicator if necessary.
    [_owningWindow removeObserver:self forKeyPath:@"firstResponder"];
    _owningWindow = [self window];
    [_owningWindow addObserver:self
                    forKeyPath:@"firstResponder"
                       options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                       context:NULL];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSView *firstResponder = (NSView *)[[self window] firstResponder];

    if (![firstResponder isKindOfClass:[NSView class]])
    {
        return;
    }

    if ([firstResponder isDescendantOf:self])
    {
        [self drawFocusIndicator];
    }
}

#pragma mark -
#pragma mark NSKeyValueObserving methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ((object == [self window]) && [keyPath isEqualToString:@"firstResponder"])
    {
        NSView *oldFirstResponder = [change objectForKey:NSKeyValueChangeOldKey];
        NSView *newFirstResponder = [change objectForKey:NSKeyValueChangeNewKey];

        if (([oldFirstResponder isKindOfClass:[NSView class]] && [oldFirstResponder isDescendantOf:self])
            || ([newFirstResponder isKindOfClass:[NSView class]] && [newFirstResponder isDescendantOf:self]))
        {
            [self invalidateFocusIndicator];
        }
    }
}

@end
