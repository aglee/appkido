//
//  AKDevToolsPanelController.m
//  AppKiDo
//
//  Created by Andy Lee on 8/10/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKDevToolsPanelController.h"

#import "DIGSLog.h"
#import "AKPrefUtils.h"
#import "AKDevToolsViewController.h"

@implementation AKDevToolsPanelController

@synthesize devToolsView = _devToolsView;
@synthesize okButton = _okButton;

#pragma mark -
#pragma mark Init/awake/dealloc


#pragma mark -
#pragma mark Running the panel

+ (BOOL)runDevToolsSetupPanel
{
    AKDevToolsPanelController *wc = [[self alloc] initWithWindowNibName:@"DevToolsPanel"];
    NSInteger result = [[NSApplication sharedApplication] runModalForWindow:wc.window];

    [wc.window orderOut:self];  // [agl] needed?

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

#pragma mark -
#pragma mark NSWindowController methods

- (void)windowDidLoad
{
    // Plug the dev tools view into the window.
    _devToolsViewController = [[AKDevToolsViewController alloc] initWithNibName:@"DevToolsView"
                                                                         bundle:nil];
    NSView *realDevToolsView = _devToolsViewController.view;
    
    realDevToolsView.frame = _devToolsView.frame;
    realDevToolsView.autoresizingMask = _devToolsView.autoresizingMask;
    [_devToolsView.superview replaceSubview:_devToolsView with:realDevToolsView];
    self.devToolsView = realDevToolsView;

    // Tell the dev tools view controller where the OK button is.
    _devToolsViewController.okButton = _okButton;
}

@end
