//
//  AKDevToolsPathController.m
//  AppKiDo
//
//  Created by Andy Lee on 6/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AKDevToolsPathController.h"

#import "DIGSLog.h"
#import "AKFileUtils.h"
#import "AKPrefUtils.h"
#import "AKMacDevTools.h"
#import "AKIPhoneDevTools.h"

@implementation AKDevToolsPathController

#pragma mark -
#pragma mark Init/awake/dealloc

- (void)awakeFromNib
{
    if ([AKPrefUtils devToolsPathPref])
    {
        [_devToolsPathField setStringValue:[AKPrefUtils devToolsPathPref]];
    }
    else
    {
        [_devToolsPathField setStringValue:@""];
    }

    [self populateSDKPopUpButton];
    [_sdkVersionsPopUpButton selectItemWithTitle:[AKPrefUtils sdkVersionPref]];
}

- (void)dealloc
{
    DIGSLogDebug_EnteringMethod();

    [_devToolsPathField release];
    [_sdkVersionsPopUpButton release];

    [super dealloc];
}


#pragma mark -
#pragma mark Getters and setters

+ (BOOL)looksLikeValidDevToolsPath:(NSString *)devToolsPath
{
    NSEnumerator *expectedSubdirsEnum = [[NSArray arrayWithObjects:
#if APPKIDO_FOR_IPHONE
        @"Platforms/iPhoneOS.platform",
        @"Platforms/iPhoneSimulator.platform",
#endif
        @"Applications/Xcode.app",
        @"Documentation",
        @"Examples",
        nil] objectEnumerator];
    NSString *subdir;

    while ((subdir = [expectedSubdirsEnum nextObject]))
    {
        NSString *expectedSubdirPath = [devToolsPath stringByAppendingPathComponent:subdir];
        if (![AKFileUtils directoryExistsAtPath:expectedSubdirPath])
        {
            DIGSLogDebug(@"%@ doesn't seem to be a valid Dev Tools path -- it doesn't have a subdirectory %@",
                devToolsPath, subdir);
            return NO;
        }
    }

    // If we got this far, we're going to assume the path is a valid Dev Tools path.
    return YES;
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
    DIGSLogInfo_ObjectDescription(@"selectSDKVersion", [[(NSPopUpButton *)sender selectedItem] title]);
    [AKPrefUtils setSDKVersionPref:[[(NSPopUpButton *)sender selectedItem] title]];
}


#pragma mark -
#pragma mark Running the panel

- (void)populateSDKPopUpButton
{
#if APPKIDO_FOR_IPHONE
    AKIPhoneDevTools *devTools = [AKIPhoneDevTools devToolsWithPath:[_devToolsPathField stringValue]];
#else
    AKMacDevTools *devTools = [AKMacDevTools devToolsWithPath:[_devToolsPathField stringValue]];
#endif
    NSEnumerator *sdkVersionsEnum = [[devTools sdkVersions] objectEnumerator];
    NSString *sdkVersion;

    [_sdkVersionsPopUpButton removeAllItems];
    while ((sdkVersion = [sdkVersionsEnum nextObject]))
    {
        [_sdkVersionsPopUpButton addItemWithTitle:sdkVersion];
    }
}


#pragma mark -
#pragma mark Modal delegate support

// Called when the user has selected a (seemingly) valid Dev Tools path.
- (void)_acceptDevToolsPath:(NSString *)selectedDir
{
    DIGSLogInfo_ObjectDescription(@"selectedDir", selectedDir);
    [_devToolsPathField setStringValue:selectedDir];
    [AKPrefUtils setDevToolsPathPref:selectedDir];
    [self populateSDKPopUpButton];
}

// Called by -_devToolsOpenPanelDidEnd:returnCode:contextInfo: if the user
// selects a directory that does not look like a valid Dev Tools directory.
- (void)_showBadPathAlert:(NSString *)selectedDir
{
    DIGSLogDebug_EnteringMethod();

    NSBeginAlertSheet(
        @"Invalid Dev Tools path",  // title
        @"OK",  // defaultButton
        @"Cancel",  // alternateButton
        nil,  // otherButton
        [_devToolsPathField window],  // docWindow
        [self retain],  // modalDelegate -- will release when alert ends
        @selector(_badPathAlertDidEnd:returnCode:contextInfo:),  // didEndSelector
        (SEL)NULL,  // didDismissSelector
        (void *)NULL,  // contextInfo
        @"'%@' doesn't look like a valid Dev Tools path.  Would you like to select another?",  // msg
        selectedDir
    );
}

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

        if ([[self class] looksLikeValidDevToolsPath:selectedDir])
        {
            [self _acceptDevToolsPath:selectedDir];
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

// Called when the alert sheet opened by -_showBadPathAlert is dismissed.
- (void)_badPathAlertDidEnd:(NSOpenPanel *)panel
    returnCode:(int)returnCode
    contextInfo:(void *)contextInfo
{
    DIGSLogDebug_EnteringMethod();

    [self autorelease];  // was retained by -_showBadPathAlert

    if (returnCode == NSOKButton)  // "OK" means try the open panel again
    {
        [self
            performSelector:@selector(runOpenPanel:)
            withObject:nil
            afterDelay:(NSTimeInterval)0.0];
    }
}

@end
