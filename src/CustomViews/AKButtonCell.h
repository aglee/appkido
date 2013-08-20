//
//  AKButtonCell.h
//  AppKiDo
//
//  Created by Andy Lee on 2/28/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 * Allows you to specify the color of the button's title text, both when the
 * button is enabled and when it's disabled.
 *
 * The implementation uses the technique learned from
 * <http://stackoverflow.com/questions/6370500/nsbutton-set-text-color-in-disabled-mode/10632311#10632311>.
 *
 * I created this class because with a very small button (it just has a triangle
 * "character" as its title) I find it a little hard to distinguish the enabled
 * and disabled states.
 *
 * HOW TO USE
 * ----------
 * In IB, select a button's cell and change the cell's class to AKButtonCell.
 * You can leave it that, in which case you will get this class's default text
 * colors, or you can specify your own text colors.
 */
@interface AKButtonCell : NSButtonCell
{
@private
    NSColor *_enabledTextColor;
    NSColor *_disabledTextColor;
}

/*! Defaults to a very dark gray (not quite black). */
@property (nonatomic, copy) NSColor *enabledTextColor;

/*! Defaults to a slightly lighter gray than Cocoa uses by default. */
@property (nonatomic, copy) NSColor *disabledTextColor;

@end
