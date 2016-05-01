/*
 * AKColoredBox.m
 *
 * Created by Andy Lee on Fri Jul 04 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKColoredBox.h"

@implementation AKColoredBox

- (void)drawRect:(NSRect)rect
{
    [[NSColor colorWithCalibratedWhite:0.87 alpha:1.0] set];
    NSRectFill(rect);
}

@end
