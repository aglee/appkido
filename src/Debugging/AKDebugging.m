//
//  AKDebugging.m
//  AppKiDo
//
//  Created by Andy Lee on 2/28/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKDebugging.h"

#import "AKAppDelegate.h"
#import "AKTestDocParserWindowController.h"
#import "AKWindow.h"
#import "AKWindowController.h"

#import "NSObject+AppKiDo.h"

@implementation AKDebugging

#pragma mark -
#pragma mark Factory methods

+ (AKDebugging *)sharedInstance
{
    static AKDebugging *s_sharedInstance = nil;

    if (!s_sharedInstance)
    {
        s_sharedInstance = [[self alloc] init];
    }

    return s_sharedInstance;
}

#pragma mark -
#pragma mark Initial setup

+ (BOOL)userCanDebug
{
    return ([NSUserName() isEqualToString:@"alee"]
            && [NSFullUserName() isEqualToString:@"Andy Lee"]);
}

- (void)addDebugMenu
{
    // Add the "Debug" menu item to the menu bar.
    NSMenu *mainMenu = [NSApp mainMenu];
    NSMenuItem *debugMenuItem = [mainMenu addItemWithTitle:@"Debug"
                                                    action:@selector(testParser:)
                                             keyEquivalent:@""];
    [debugMenuItem setEnabled:YES];

    // Create the submenu that will be under the "Debug" top-level menu item.
    NSMenu *debugSubmenu = [[[NSMenu alloc] initWithTitle:@"Debug"] autorelease];

    [debugSubmenu setAutoenablesItems:NO];

    [debugSubmenu addItemWithTitle:@"Print First Responder"
                            action:@selector(printFirstResponder:)
                     keyEquivalent:@"r"];
    [debugSubmenu addItemWithTitle:@"Print Tab Chain"
                            action:@selector(printTabChain:)
                     keyEquivalent:@"l"];
    [debugSubmenu addItemWithTitle:@"Print nextValidKeyView Loop"
                            action:@selector(printValidKeyViewLoop:)
                     keyEquivalent:@"L"];
    [debugSubmenu addItemWithTitle:@"Print nextKeyView Loop"
                            action:@selector(printEntireKeyViewLoop:)
                     keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"Print Window Info"
                            action:@selector(printFunWindowFacts:)
                     keyEquivalent:@"i"];
    [debugSubmenu addItemWithTitle:@"Open Parser Testing Window"
                            action:@selector(testParser:)
                     keyEquivalent:@""];

    // Attach the submenu to the "Debug" top-level menu item.
    [mainMenu setSubmenu:debugSubmenu forItem:debugMenuItem];
}

#pragma mark -
#pragma mark Action methods

- (IBAction)testParser:(id)sender
{
    [AKTestDocParserWindowController openNewParserWindow];
}

- (IBAction)printFirstResponder:(id)sender
{
    id firstResponder = [[NSApp keyWindow] firstResponder];

    if (firstResponder == nil)
    {
        NSLog(@"The key window has no first responder.\n\n");
    }
    else
    {
        NSLog(@"The key window's first responder is <%@: %p>.\n\n", [firstResponder className], firstResponder);
    }
}

- (IBAction)printTabChain:(id)sender
{
    if (![[NSApp keyWindow] isKindOfClass:[AKWindow class]])
    {
        NSLog(@"The key window is not an AKWindow.\n\n");
    }
    else
    {
        [(AKWindow *)[NSApp keyWindow] printTabChains];
    }
}

- (IBAction)printValidKeyViewLoop:(id)sender
{
    [self _printViewSequenceUsingSelector:@selector(nextValidKeyView)];
}

- (IBAction)printEntireKeyViewLoop:(id)sender
{
    [self _printViewSequenceUsingSelector:@selector(nextKeyView)];
}

- (IBAction)printFunWindowFacts:(id)sender
{
    AKWindowController *wc = [(AKAppDelegate *)[NSApp delegate] frontmostWindowController];

    if (wc == nil)
    {
        NSLog(@"No AppKiDo window is open.");
    }
    else
    {
        [wc printFunFacts:sender];
    }
}

#pragma mark -
#pragma mark Private methods

- (void)_printViewSequenceUsingSelector:(SEL)nextViewSelector
{
    [self printFirstResponder:nil];
    
    id firstResponder = [[NSApp keyWindow] firstResponder];

    if ([firstResponder isKindOfClass:[NSView class]])
    {
        [firstResponder ak_printSequenceUsingSelector:nextViewSelector];
    }
}

@end
