/*
 * AKApplication.m
 *
 * Created by Andy Lee on Thu Mar 18 2007.
 * Copyright (c) 2003-2007 Andy Lee. All rights reserved.
 */

#import "AKApplication.h"
#import <WebKit/WebKit.h>
#import "AKTabChain.h"
#import "AKWindow.h"
#import "AKWindowController.h"

@implementation AKApplication

- (void)sendEvent:(NSEvent *)anEvent
{
    if ([AKTabChain handlePossibleTabChainEvent:anEvent])
    {
        return;
    }
    
    [super sendEvent:anEvent];
}

@end
