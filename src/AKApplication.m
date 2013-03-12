/*
 * AKApplication.m
 *
 * Created by Andy Lee on Thu Mar 18 2007.
 * Copyright (c) 2003-2007 Andy Lee. All rights reserved.
 */

#import "AKApplication.h"
#import <WebKit/WebKit.h>
#import "AKWindow.h"

@implementation AKApplication

- (void)sendEvent:(NSEvent *)anEvent
{
    NSWindow *keyWindow = [self keyWindow];

    if ([keyWindow isKindOfClass:[AKWindow class]]
        && [(AKWindow *)keyWindow maybeHandleTabChainEvent:anEvent])
    {
        return;
    }

    // If we got this far, handle the event in the default way.
    [super sendEvent:anEvent];
}

@end
