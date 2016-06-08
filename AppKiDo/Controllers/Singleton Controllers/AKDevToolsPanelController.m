//
//  AKDevToolsPanelController.m
//  AppKiDo
//
//  Created by Andy Lee on 8/10/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKDevToolsPanelController.h"
#import "AKDevToolsViewController.h"
#import "AKPrefUtils.h"
#import "DIGSLog.h"

@implementation AKDevToolsPanelController
{
	AKDevToolsViewController *_devToolsViewController;
}

#pragma mark - Running the panel

+ (BOOL)runDevToolsSetupPanel
{
    AKDevToolsPanelController *wc = [[self alloc] initWithWindowNibName:@"DevToolsPanel"];
    NSInteger result = [[NSApplication sharedApplication] runModalForWindow:wc.window];

    [wc.window orderOut:self];  //TODO: Is this needed?

	return (result == NSRunStoppedResponse);
}

#pragma mark - Action methods

- (IBAction)ok:(id)sender
{
    [[NSApplication sharedApplication] stopModal];
}

- (IBAction)cancel:(id)sender
{
    [[NSApplication sharedApplication] terminate:self];
}

#pragma mark - NSWindowController methods

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
}

@end
