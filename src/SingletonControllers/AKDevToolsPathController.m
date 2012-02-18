//
//  AKDevToolsPathController.m
//  AppKiDo
//
//  Created by Andy Lee on 6/17/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKDevToolsPathController.h"

#import "DIGSLog.h"
#import "AKPrefUtils.h"
#import "AKMacDevTools.h"
#import "AKIPhoneDevTools.h"


@interface AKDevToolsPathController (Private)
- (void)_populateSDKPopUpButton;
@end


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
    [self _populateSDKPopUpButton];
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
         beginSheetForDirectory: @"/"
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
#pragma mark Private methods

// Fills in the popup button that lists available SDK versions.  Gets this list
// by looking in the directory specified by [AKPrefUtils devToolsPathPref].
// If we find any SDKs for which we have a docset but no headers, we display
// a message to this effect in _missingSDKWarningsField.
- (void)_populateSDKPopUpButton
{
    NSString *devToolsPath = [AKPrefUtils devToolsPathPref];
#if APPKIDO_FOR_IPHONE
    AKIPhoneDevTools *devTools = [AKIPhoneDevTools devToolsWithPath:devToolsPath];
#else
    AKMacDevTools *devTools = [AKMacDevTools devToolsWithPath:devToolsPath];
#endif
    NSMutableArray *sdkVersionsWithHeaders = [NSMutableArray array];
    NSMutableArray *sdkVersionsWithoutHeaders = [NSMutableArray array];
    NSEnumerator *sdkVersionsEnum = [[devTools sdkVersionsThatHaveDocSets] objectEnumerator];
    NSString *sdkVersion;
    
    [_sdkVersionsPopUpButton removeAllItems];
    while ((sdkVersion = [sdkVersionsEnum nextObject]))
    {
        if ([devTools sdkPathForSDKVersion:sdkVersion] == nil)
        {
            DIGSLogInfo(@"found docs but not headers for version [%@]", sdkVersion);
            [sdkVersionsWithoutHeaders addObject:sdkVersion];
        }
        else
        {
            [sdkVersionsWithHeaders addObject:sdkVersion];
            [_sdkVersionsPopUpButton addItemWithTitle:sdkVersion];
        }
    }
    
    NSMutableString *explanationString = [NSMutableString string];
    
    if ([sdkVersionsWithoutHeaders count] > 0)
    {
        [explanationString appendFormat:@"Found docsets but not SDKs for these SDK versions: %@.\n\n",
         [sdkVersionsWithoutHeaders componentsJoinedByString:@", "]];
    }
    [explanationString appendFormat:@"Search paths for docsets: %@.\n\n",
     [[devTools docSetSearchPaths] componentsJoinedByString:@", "]];
    [explanationString appendFormat:@"Search path for SDKs: %@.\n\n", [devTools sdkSearchPath]];
    [_explanationField setStringValue:explanationString];
    
    NSString *selectedSDKVersion = [AKPrefUtils sdkVersionPref];
    if (selectedSDKVersion == nil
        || ![[devTools sdkVersionsThatHaveDocSets] containsObject:selectedSDKVersion])
    {
        selectedSDKVersion = [sdkVersionsWithHeaders lastObject];
        [AKPrefUtils setSDKVersionPref:selectedSDKVersion];
    }
    [_sdkVersionsPopUpButton selectItemWithTitle:selectedSDKVersion];
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
        selectedDir = [selectedDir stringByAppendingPathComponent: @"Xcode.app"];
        selectedDir = [selectedDir stringByAppendingPathComponent: @"Contents"];
        selectedDir = [selectedDir stringByAppendingPathComponent: @"Developer"];
        
        
        NSMutableArray *errorStrings = [NSMutableArray array];

        if ([AKDevTools looksLikeValidDevToolsPath:selectedDir errorStrings:errorStrings])
        {
            [_devToolsPathField setStringValue:selectedDir];
            [AKPrefUtils setDevToolsPathPref:selectedDir];
            [self _populateSDKPopUpButton];
        }
        else
        {
            NSString *errorMessage = [NSString stringWithFormat:@"\"%@\" doesn't look like a valid Dev Tools path.\n\n%@",
                                      selectedDir,
                                      [errorStrings componentsJoinedByString:@"\n"]];
            [self
                performSelector:@selector(_showBadPathAlert:)
                withObject:errorMessage
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
- (void)_showBadPathAlert:(NSString *)errorMessage
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
        @"%@",  // msg
        errorMessage
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
