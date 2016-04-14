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

// We override all of NSCell's designated initializers, as we should.
// This function performs initialization common to them all.
static void _common_init(AKButtonCell *self)
{
    self->_enabledTextColor = [[NSColor redColor] retain];  //[AKButtonCellEnabledTextColor retain];
    self->_disabledTextColor = [AKButtonCellDisabledTextColor retain];
}

- (id)initImageCell:(NSImage *)anImage
{
    self = [super initImageCell:anImage];
    if (self)
    {
        _common_init(self);
    }

    return self;
}

- (id)initTextCell:(NSString *)aString
{
    self = [super initTextCell:aString];
    if (self)
    {
        _common_init(self);
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _common_init(self);
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

// Overridden to draw the title in the color of my choice when a button is disabled.
// Apple's default behavior is to pass an all-gray version of the cell's title
// to this method. This override replaces the gray with a different color.
- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
    NSMutableParagraphStyle *style = [[[NSMutableParagraphStyle alloc] init] autorelease];
    [style setAlignment:[self alignment]];

    NSColor *textColor = ([self isEnabled]
                          ? [self enabledTextColor]
                          : [self disabledTextColor]);
    NSDictionary *textAttributes = (@{
                                      NSFontAttributeName: [self font],
                                      NSForegroundColorAttributeName: textColor,
                                      NSParagraphStyleAttributeName: style,
                                      });

    title = [[[NSAttributedString alloc] initWithString:[title string]
                                             attributes:textAttributes] autorelease];
    
    return [super drawTitle:title withFrame:frame inView:controlView];
}

@end
