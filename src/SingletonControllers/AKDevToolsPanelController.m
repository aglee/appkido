//
//  AKDevToolsPanelController.m
//  AppKiDo
//
//  Created by Andy Lee on 8/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKDevToolsPanelController.h"

#import "DIGSLog.h"
#import "AKPrefUtils.h"
#import "AKDevToolsPathController.h"

@implementation AKDevToolsPanelController


#pragma mark -
#pragma mark Factory methods

+ (id)controller
{
    return [[[self alloc] init] autorelease];
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)init
{
    if ((self = [super init]))
    {
        if (![NSBundle loadNibNamed:@"DevToolsPath" owner:self])
        {
            DIGSLogDebug(@"Failed to load DevToolsPath");
            [self release];
            return nil;
        }
    }

    return self;
}

- (void)dealloc
{
    DIGSLogDebug_EnteringMethod();

    [_window release];
    [_devToolsPathController release];

    [super dealloc];
}


#pragma mark -
#pragma mark Running the panel

- (BOOL)runDevToolsSetupPanel
{
    DIGSLogDebug_EnteringMethod();

    int result = [[NSApplication sharedApplication] runModalForWindow:_window];

    DIGSLogDebug(@"result of Dev Tools path panel: %d", result);
    [_window orderOut:self];

	return (result == NSRunStoppedResponse);
}


#pragma mark -
#pragma mark Action methods

- (IBAction)ok:(id)sender
{
    DIGSLogDebug_EnteringMethod();
    [[NSApplication sharedApplication] stopModal];
}

- (IBAction)cancel:(id)sender
{
    DIGSLogDebug_EnteringMethod();
    [[NSApplication sharedApplication] terminate:self];
}

@end
