//
//  AKDebugging.m
//  AppKiDo
//
//  Created by Andy Lee on 2/28/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "AKDebugging.h"

#import "AKTestDocParserWindowController.h"
#import "AKViewUtils.h"

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

    [debugSubmenu addItemWithTitle:@"Open Parser Testing Window"
                            action:@selector(testParser:)
                     keyEquivalent:@""];
    [debugSubmenu addItemWithTitle:@"Print Key View Loop"
                            action:@selector(printKeyViewLoop:)
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

- (IBAction)printKeyViewLoop:(id)sender
{
    id firstResponder = [[NSApp keyWindow] firstResponder];

    if (firstResponder == nil)
    {
        NSLog(@"there's no first responder");
    }
    else
    {
        NSLog(@"key window's first responder is %@ at %p", [firstResponder className], firstResponder);

        if ([firstResponder isKindOfClass:[NSView class]])
        {
            [firstResponder ak_printKeyViewLoop];
            [firstResponder ak_printReverseKeyViewLoop];
        }
    }
}

@end
