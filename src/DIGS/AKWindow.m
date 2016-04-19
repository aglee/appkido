/*
 * AKWindow.m
 *
 * Created by Andy Lee on Wed Apr 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKWindow.h"

@implementation AKWindow

#pragma mark -
#pragma mark NSWindow methods

// As suggested by Gerriet Denkmann.  Protects against crashing due to nil.
- (void)setTitle:(NSString *)aString
{
	if (aString == nil)
	{
		aString = @"*** nil ***";
	}

	super.title = aString;
}

/** Intercept cmd-L as equivalent to sh-cmd-F
 
 @author    Fritz Anderson <fritza@mac.com>
 @date      13-May-2014
 
 I keep hitting cmd-L as though the application had
 a browser-style address/search bar. I see no harm
 in honoring the usual key equivalent.
 
 @bug   This method puts a hidden restriction on the use of cmd-L
        for other purposes.
 */
- (void) keyDown:(NSEvent *)theEvent
{
    NSString *      chars = theEvent.characters;
    NSUInteger      modifiers = theEvent.modifierFlags & NSDeviceIndependentModifierFlagsMask;
    BOOL            onlyCmdKey = (modifiers == NSCommandKeyMask);

    if ([chars isEqualToString: @"l"] && onlyCmdKey) {
        [NSApp sendAction: @selector(selectSearchField:) to: nil from: self];
    }
    else {
        [super keyDown: theEvent];
    }
}

@end
