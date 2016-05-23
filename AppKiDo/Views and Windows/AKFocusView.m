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

#pragma mark - Init/dealloc/awake

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self)
    {
        [self _startObservingKeyWindowChanges];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _startObservingKeyWindowChanges];
    }

    return self;
}

- (void)awakeFromNib
{
    [self resizeSubviewsWithOldSize:self.bounds.size];
}

- (void)dealloc
{
    [self _stopObservingKeyWindowChanges];
    [self _stopObservingFirstResponderChanges];

}

#pragma mark - Focus ring

//TODO: maybe someday make these public methods so subclasses can customize

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
    NSColor *focusRingColor = (self.window.keyWindow
                               ? [NSColor keyboardFocusIndicatorColor]
                               : [NSColor darkGrayColor]);
    [focusRingColor set];
    NSFrameRectWithWidth(self.bounds, AKFocusBorderThickness);
}

#pragma mark - NSView methods

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
    // Assume we have exactly one subview.
    NSView *innerView = self.subviews.lastObject;

    // Inset the inner view slightly within our bounds. This means I don't have
    // to be precise about positioning the inner view in IB, because I know it
    // will be adjusted here.
    innerView.frame = NSInsetRect(self.bounds, AKFocusBorderThickness, AKFocusBorderThickness);
    innerView.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);

    // Suppress any focus ring that would normally be drawn by the inner view.
    //TODO: Could someday make this conditional; we don't use the built-in
    // focus ring stuff, but a subclass might want to.
    innerView.focusRingType = NSFocusRingTypeNone;
    if ([innerView isKindOfClass:[NSScrollView class]])
    {
        [((NSScrollView *)innerView).documentView setFocusRingType:NSFocusRingTypeNone];
    }
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
    [self _stopObservingFirstResponderChanges];
    
    [super viewWillMoveToWindow:newWindow];
}

- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    
    [self _startObservingFirstResponderChanges];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSView *firstResponder = (NSView *)self.window.firstResponder;

    if (![firstResponder isKindOfClass:[NSView class]])
    {
        return;
    }

    if ([firstResponder isDescendantOf:self])
    {
        [self drawFocusIndicator];
    }
}

#pragma mark - NSKeyValueObserving methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ((object == self.window) && [keyPath isEqualToString:@"firstResponder"])
    {
        NSView *oldFirstResponder = change[NSKeyValueChangeOldKey];
        NSView *newFirstResponder = change[NSKeyValueChangeNewKey];

        if (([oldFirstResponder isKindOfClass:[NSView class]] && [oldFirstResponder isDescendantOf:self])
            || ([newFirstResponder isKindOfClass:[NSView class]] && [newFirstResponder isDescendantOf:self]))
        {
            [self invalidateFocusIndicator];
        }
    }
}

#pragma mark - Private methods

- (void)_startObservingKeyWindowChanges
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleKeyWindowChangedNotification:)
                                                 name:NSWindowDidBecomeKeyNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleKeyWindowChangedNotification:)
                                                 name:NSWindowDidResignKeyNotification
                                               object:nil];
}

- (void)_stopObservingKeyWindowChanges
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSWindowDidBecomeKeyNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSWindowDidResignKeyNotification
                                                  object:nil];
}

- (void)_startObservingFirstResponderChanges
{
    [self.window addObserver:self
                    forKeyPath:@"firstResponder"
                       options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                       context:NULL];
}

- (void)_stopObservingFirstResponderChanges
{
    [self.window removeObserver:self forKeyPath:@"firstResponder"];
}

// We get this notification when *any* window becomes or resigns key window.
// We don't do anything unless we are in either the given window or one of the
// given window's drawers.
- (void)_handleKeyWindowChangedNotification:(NSNotification *)notif
{
    if ([self _belongsToWindow:notif.object])
    {
        [self invalidateFocusIndicator];
    }
}

- (BOOL)_belongsToWindow:(NSWindow *)window
{
    if (window == self.window)
    {
        return YES;
    }

    for (NSDrawer *drawer in window.drawers)
    {
        if ([self isDescendantOf:drawer.contentView])
        {
            return YES;
        }
    }

    return NO;
}

@end
