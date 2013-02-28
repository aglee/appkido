//
//  AKButtonCell.m
//  AppKiDo
//
//  Created by Andy Lee on 2/28/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKButtonCell.h"

@implementation AKButtonCell

// Technique learned from http://stackoverflow.com/questions/6370500/nsbutton-set-text-color-in-disabled-mode/10632311#10632311 for drawing the title in the color of my choice when a button is disabled. It looks like Apple passes an all-gray attributed string to this method.
- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
    // Hack the color of the title.
    NSMutableParagraphStyle *style = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [style setAlignment:NSCenterTextAlignment];

    NSColor *textColor = ([self isEnabled]
                          ? [NSColor colorWithCalibratedWhite:0.2 alpha:1.0]
                          : [NSColor colorWithCalibratedWhite:0.6 alpha:1.0]);
    NSDictionary *attr = (@{
                          NSFontAttributeName: [self font],
                          NSForegroundColorAttributeName: textColor,
                          NSParagraphStyleAttributeName: style,
                          });

    title = [[[NSAttributedString alloc] initWithString:[title string]
                                             attributes:attr] autorelease];
    
    return [super drawTitle:title withFrame:frame inView:controlView];
}

@end
