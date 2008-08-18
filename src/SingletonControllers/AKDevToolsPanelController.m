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

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)controller
{
    return [[[self alloc] init] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

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

        _textFieldController =
            [[AKDevToolsPathController alloc]
                initWithTextField:_devToolsPathField];
    }

    return self;
}

- (void)dealloc
{
    DIGSLogEnteringMethod();

    [_textFieldController release];
    [[_devToolsPathField window] release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Running the panel
//-------------------------------------------------------------------------

- (void)promptForDevToolsPath
{
    DIGSLogEnteringMethod();

    NSString *oldPath = [AKPrefUtils devToolsPathPref];

    if (oldPath == nil)
    {
        [_devToolsPathField setStringValue:@""];
    }
    else
    {
        [_devToolsPathField setStringValue:oldPath];
    }

    int result =
        [[NSApplication sharedApplication]
            runModalForWindow:[_devToolsPathField window]];

    DIGSLogDebug(@"result of Dev Tools path panel: %d", result);
    [[_devToolsPathField window] orderOut:self];
}

//-------------------------------------------------------------------------
// Action methods
//-------------------------------------------------------------------------

- (IBAction)runOpenPanel:(id)sender
{
    DIGSLogEnteringMethod();
    [_textFieldController runOpenPanel];
}

- (IBAction)ok:(id)sender
{
    DIGSLogEnteringMethod();
    [[NSApplication sharedApplication] stopModal];
}

- (IBAction)cancel:(id)sender
{
    DIGSLogEnteringMethod();
    [[NSApplication sharedApplication] terminate:self];
}

@end
