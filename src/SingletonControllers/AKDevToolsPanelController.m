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

        _textFieldController = [[AKDevToolsPathController alloc] init];
        [_textFieldController setDevToolsPathField:_devToolsPathField];
        [_textFieldController setDocSetsPopUpButton:_docSetsPopUpButton];
    }

    return self;
}

- (void)dealloc
{
    DIGSLogDebug_EnteringMethod();

    [_textFieldController release];
    [[_devToolsPathField window] release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Running the panel
//-------------------------------------------------------------------------

- (void)promptForDevToolsPath
{
    DIGSLogDebug_EnteringMethod();

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
    DIGSLogDebug_EnteringMethod();
    [_textFieldController runOpenPanel];
}

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
