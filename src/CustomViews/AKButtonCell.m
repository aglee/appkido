//
//  AKButtonCell.m
//  AppKiDo
//
//  Created by Andy Lee on 2/28/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKButtonCell.h"

@implementation AKButtonCell

@synthesize enabledTextColor = _enabledTextColor;
@synthesize disabledTextColor = _disabledTextColor;

#define AKButtonCellEnabledTextColor [NSColor colorWithCalibratedWhite:0.2 alpha:1.0]
#define AKButtonCellDisabledTextColor [NSColor colorWithCalibratedWhite:0.6 alpha:1.0]

#pragma mark -
#pragma mark NSCell methods

- (void)_AKButtonCell_common_init
{
    _enabledTextColor = [AKButtonCellEnabledTextColor retain];
    _disabledTextColor = [AKButtonCellDisabledTextColor retain];
}

- (id)initImageCell:(NSImage *)anImage
{
    self = [super initImageCell:anImage];
    if (self)
    {
        [self _AKButtonCell_common_init];
    }

    return self;
}

- (id)initTextCell:(NSString *)aString
{
    self = [super initTextCell:aString];
    if (self)
    {
        [self _AKButtonCell_common_init];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _AKButtonCell_common_init];
    }

    return self;
}

- (void)dealloc
{
    [_enabledTextColor release];
    [_disabledTextColor release];

    [super dealloc];
}

#pragma mark -
#pragma mark Getters and setters

- (void)setEnabledTextColor:(NSColor *)enabledTextColor
{
    [enabledTextColor retain];
    [_enabledTextColor release];
    _enabledTextColor = enabledTextColor;

    [[self controlView] setNeedsDisplay:YES];
}

- (void)setDisabledTextColor:(NSColor *)disabledTextColor
{
    [disabledTextColor retain];
    [_disabledTextColor release];
    _disabledTextColor = disabledTextColor;

    [[self controlView] setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark NSButtonCell methods

// 
// for drawing the title in the color of my choice when a button is disabled.
// Apple's default behavior is to pass an all-gray version of the cell's title
// to this method. This override replaces the gray with a different color.
- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
    NSMutableParagraphStyle *style = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [style setAlignment:[self alignment]];

    NSColor *textColor = ([self isEnabled]
                          ? [self enabledTextColor]
                          : [self disabledTextColor]);
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
