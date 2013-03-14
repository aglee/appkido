/*
 * AKApplication.m
 *
 * Created by Andy Lee on Thu Mar 18 2007.
 * Copyright (c) 2003-2007 Andy Lee. All rights reserved.
 */

#import "AKApplication.h"
#import <WebKit/WebKit.h>
#import "AKWindow.h"
#import "AKWindowController.h"

@implementation AKApplication

- (void)sendEvent:(NSEvent *)anEvent
{
    NSWindow *keyWindow = [self keyWindow];

    if ([keyWindow isKindOfClass:[AKWindow class]]
        && [AKWindow isTabChainEvent:anEvent forward:NULL])
    {
        if ([[keyWindow delegate] isKindOfClass:[AKWindowController class]])
        {
            // Recalculate the window's tab chain, in case something has
            // happened recently that would affect the key view loop. For
            // example, the user might have switched the Full Keyboard Access
            // flag in System Preferences.
            [keyWindow recalculateKeyViewLoop];
            [(AKWindowController *)[keyWindow delegate] recalculateTabChains];
        }
        
        if ([(AKWindow *)keyWindow handlePossibleTabChainEvent:anEvent])
        {
            return;
        }
    }

    // If we got this far, handle the event in the default way.
    [super sendEvent:anEvent];
}

@end
