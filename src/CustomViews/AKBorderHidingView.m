//
//  AKBorderHidingView.m
//  AppKiDo
//
//  Created by Andy Lee on 3/11/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKBorderHidingView.h"

@implementation AKBorderHidingView

static const CGFloat AKThicknessOfBorderToHide = 1;

- (void)awakeFromNib
{
    NSView *innerView = [[self subviews] lastObject];

    [innerView setFrame:NSInsetRect([self bounds],
                                    -AKThicknessOfBorderToHide,
                                    -AKThicknessOfBorderToHide)];
    [innerView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor redColor] set];
    NSRectFill([self bounds]);
}

@end
