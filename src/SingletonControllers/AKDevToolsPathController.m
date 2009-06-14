//
//  AKDevToolsPathController.m
//  AppKiDo
//
//  Created by Andy Lee on 6/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKDevToolsPathController.h"

#import "DIGSLog.h"
#import "AKPrefUtils.h"
#import "AKMacDevTools.h"
#import "AKIPhoneDevTools.h"

@implementation AKDevToolsPathController

#pragma mark -
#pragma mark Init/awake/dealloc

- (void)awakeFromNib
{
    // Put initial value in _devToolsPathField.
    if ([AKPrefUtils devToolsPathPref])
        [_devToolsPathField setStringValue:[AKPrefUtils devToolsPathPref]];
    else
        [_devToolsPathField setStringValue:@""];

    // Put initial values in _sdkVersionsPopUpButton.
    [self populateSDKPopUpButton];
}

- (void)dealloc
{
    DIGSLogDebug_EnteringMethod();

    [_devToolsPathField release];
    [_sdkVersionsPopUpButton release];

    [super dealloc];
}


#pragma mark -
#pragma mark Action methods

- (IBAction)runOpenPanel:(id)sender
{
    DIGSLogDebug_EnteringMethod();

    if (_devToolsPathField == nil)
        DIGSLogError(@"_devToolsPathField should not be nil");

    if (_sdkVersionsPopUpButton == nil)
        DIGSLogError(@"_docSetsPopUpButton should not be nil");
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setTitle:@"Select Dev Tools directory"];
    [openPanel setPrompt:@"Select"];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setResolvesAliases:YES];
    
    [openPanel
         beginSheetForDirectory:[_devToolsPathField stringValue]
         file:nil
         types:nil
         modalForWindow:[_devToolsPathField window]
         modalDelegate:[self retain]  // will release later
         didEndSelector:@selector(_devToolsOpenPanelDidEnd:returnCode:contextInfo:)
         contextInfo:(void *)NULL];
}

- (IBAction)selectSDKVersion:(id)sender
{
    DIGSLogDebug_EnteringMethod();

    [AKPrefUtils setSDKVersionPref:[[(NSPopUpButton *)sender selectedItem] title]];
}


#pragma mark -
#pragma mark Running the panel

- (void)populateSDKPopUpButton
{
    NSString *devToolsPath = [AKPrefUtils devToolsPathPref];
#if APPKIDO_FOR_IPHONE
    AKIPhoneDevTools *devTools = [AKIPhoneDevTools devToolsWithPath:devToolsPath];
#else
    AKMacDevTools *devTools = [AKMacDevTools devToolsWithPath:devToolsPath];
#endif
    NSEnumerator *sdkVersionsEnum = [[devTools sdkVersions] objectEnumerator];
    NSString *sdkVersion;

    [_sdkVersionsPopUpButton removeAllItems];
    while ((sdkVersion = [sdkVersionsEnum nextObject]))
    {
        [_sdkVersionsPopUpButton addItemWithTitle:sdkVersion];
    }

    NSString *selectedSDKVersion = [AKPrefUtils sdkVersionPref];
    if (selectedSDKVersion == nil
        || ![[devTools sdkVersions] containsObject:selectedSDKVersion])
    {
        selectedSDKVersion = [[devTools sdkVersions] lastObject];
        [AKPrefUtils setSDKVersionPref:selectedSDKVersion];
    }
    [_sdkVersionsPopUpButton selectItemWithTitle:selectedSDKVersion];
}


#pragma mark -
#pragma mark Modal delegate support

// Called when the open panel sheet opened by -runOpenPanel is dismissed.
- (void)_devToolsOpenPanelDidEnd:(NSOpenPanel *)panel
    returnCode:(int)returnCode
    contextInfo:(void *)contextInfo
{
    DIGSLogDebug_EnteringMethod();

    [self autorelease];  // was retained by -runOpenPanel

    if (returnCode == NSOKButton)
    {
        NSString *selectedDir = [panel directory];

        if ([AKDevTools looksLikeValidDevToolsPath:selectedDir])
        {
            [_devToolsPathField setStringValue:selectedDir];
            [AKPrefUtils setDevToolsPathPref:selectedDir];
            [self populateSDKPopUpButton];
        }
        else
        {
            [self
                performSelector:@selector(_showBadPathAlert:)
                withObject:selectedDir
                afterDelay:(NSTimeInterval)0.0
                inModes:
                    [NSArray arrayWithObjects:
                        NSDefaultRunLoopMode,
                        NSModalPanelRunLoopMode,
                        nil]];
        }
    }
}

// Called by -_devToolsOpenPanelDidEnd:returnCode:contextInfo: if the user
// selects a directory that does not look like a valid Dev Tools directory.
- (void)_showBadPathAlert:(NSString *)selectedDir
{
    DIGSLogDebug_EnteringMethod();

    NSBeginAlertSheet(
        @"Invalid Dev Tools path",  // title
        @"OK",  // defaultButton
        nil,  // alternateButton
        nil,  // otherButton
        [_devToolsPathField window],  // docWindow
        [self retain],  // modalDelegate -- will release when alert ends
        @selector(_badPathAlertDidEnd:returnCode:contextInfo:),  // didEndSelector
        (SEL)NULL,  // didDismissSelector
        (void *)NULL,  // contextInfo
        @"'%@' doesn't look like a valid Dev Tools path.",  // msg
        selectedDir
    );
}

// Called when the alert sheet opened by -_showBadPathAlert is dismissed.
- (void)_badPathAlertDidEnd:(NSOpenPanel *)panel
    returnCode:(int)returnCode
    contextInfo:(void *)contextInfo
{
    DIGSLogDebug_EnteringMethod();

    [self autorelease];  // was retained by -_showBadPathAlert

    [self
        performSelector:@selector(runOpenPanel:)
        withObject:nil
        afterDelay:(NSTimeInterval)0.0
        inModes:
            [NSArray arrayWithObjects:
                NSDefaultRunLoopMode,
                NSModalPanelRunLoopMode,
                nil]];
}

@end
