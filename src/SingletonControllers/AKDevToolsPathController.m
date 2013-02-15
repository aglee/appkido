//
//  AKDevToolsPathController.m
//  AppKiDo
//
//  Created by Andy Lee on 6/17/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKDevToolsPathController.h"

#import "DIGSLog.h"
#import "AKDevToolsUtils.h"
#import "AKPrefUtils.h"
#import "AKMacDevTools.h"
#import "AKIPhoneDevTools.h"


@interface AKDevToolsPathController (Private)
- (void)_populateSDKPopUpButton;
@end


@interface AKDevToolsPathController () <NSOpenSavePanelDelegate>
@end

@implementation AKDevToolsPathController

#pragma mark -
#pragma mark Init/awake/dealloc

- (void)awakeFromNib
{
    NSString *devToolsPath = [AKPrefUtils devToolsPathPref];
    NSString *xcodeAppPath = [AKDevToolsUtils xcodeAppPathFromDevToolsPath:devToolsPath];

    [self _setSelectedXcodeAppPath:xcodeAppPath];
    
    // Populate the UI with initial values.
    if (xcodeAppPath)
        [_xcodeAppPathField setStringValue:xcodeAppPath];
    else
        [_xcodeAppPathField setStringValue:@""];
    [self _populateSDKPopUpButton];
}


#pragma mark -
#pragma mark Action methods

- (IBAction)promptForXcodeLocation:(id)sender
{
    DIGSLogDebug_EnteringMethod();

    if (_xcodeAppPathField == nil)
        DIGSLogError(@"_xcodeAppPathField should not be nil");

    if (_sdkVersionsPopUpButton == nil)
        DIGSLogError(@"_docSetsPopUpButton should not be nil");
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setTitle:@"Locate Xcode.app"];
    [openPanel setPrompt:@"Select Xcode"];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setDelegate:self];
    [openPanel setResolvesAliases:YES];

    [openPanel
         beginSheetForDirectory:_selectedXcodeAppPath
         file:nil
         types:[NSArray arrayWithObject:@"app"]
         modalForWindow:[_xcodeAppPathField window]
         modalDelegate:[self retain]  // will release later
         didEndSelector:@selector(_xcodeOpenPanelDidEnd:returnCode:contextInfo:)
         contextInfo:(void *)NULL];
}

- (IBAction)selectSDKVersion:(id)sender
{
    DIGSLogDebug_EnteringMethod();

    [AKPrefUtils setSDKVersionPref:[[(NSPopUpButton *)sender selectedItem] title]];
}

#pragma mark - NSOpenSavePanelDelegate methods

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url
{
    NSString *path = [url path];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;

    // Only allow directories.
    if (![fm fileExistsAtPath:path isDirectory:&isDir])
    {
        return NO;
    }

    if (!isDir)
    {
        return NO;
    }

    // Allow any directory that is not an app bundle.
    if (![[path pathExtension] isEqualToString:@"app"])
    {
        return YES;
    }
    
    // Only allow app bundles if they seem to be Xcode.
    return [fm fileExistsAtPath:[path stringByAppendingPathComponent:@"Contents/MacOS/Xcode"]];
}

#pragma mark -
#pragma mark Private methods

- (void)_setSelectedXcodeAppPath:(NSString *)xcodeAppPath
{
    [_selectedXcodeAppPath autorelease];
    _selectedXcodeAppPath = [xcodeAppPath copy];
}

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
    
    // Update the explanation string that tells where we looked for docsets and SDKs.
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
    
    // Take the "selected SDK version" pref setting from the selected item in the SDK popup.
    NSString *selectedSDKVersion = [AKPrefUtils sdkVersionPref];
    if (selectedSDKVersion == nil
        || ![[devTools sdkVersionsThatHaveDocSets] containsObject:selectedSDKVersion])
    {
        selectedSDKVersion = [sdkVersionsWithHeaders lastObject];
        [AKPrefUtils setSDKVersionPref:selectedSDKVersion];
    }
    [_sdkVersionsPopUpButton selectItemWithTitle:selectedSDKVersion];
    
    // Update the enabledness of the OK button.
    [_okButton setEnabled:(selectedSDKVersion != nil)];
}

// Called when the open panel sheet opened by -promptForXcodeLocation: is dismissed.
- (void)_xcodeOpenPanelDidEnd:(NSOpenPanel *)panel
    returnCode:(int)returnCode
    contextInfo:(void *)contextInfo
{
    DIGSLogDebug_EnteringMethod();

    [self autorelease];  // was retained by -promptForXcodeLocation:

    if (returnCode == NSOKButton)
    {
        NSString *xcodeAppPath = [[[panel URLs] lastObject] path];
        NSMutableArray *errorStrings = [NSMutableArray array];

        //If the user selected an Xcode.app, get the /Developer that resides within, if there is one.
        [self _setSelectedXcodeAppPath:xcodeAppPath];
        
        NSString *devToolsPath = [AKDevToolsUtils devToolsPathFromPossibleXcodePath:xcodeAppPath];

        if ([AKDevTools looksLikeValidDevToolsPath:devToolsPath errorStrings:errorStrings])
        {
            [_xcodeAppPathField setStringValue:xcodeAppPath];
            [AKPrefUtils setDevToolsPathPref:devToolsPath];
            [self _populateSDKPopUpButton];
        }
        else
        {
            NSString *errorMessage = [NSString stringWithFormat:@"\"%@\" doesn't look like a valid Dev Tools path.\n\n%@",
                                      devToolsPath,
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

// Called by -_xcodeOpenPanelDidEnd:returnCode:contextInfo: if the user
// selects a directory that does not look like a valid Dev Tools directory.
- (void)_showBadPathAlert:(NSString *)errorMessage
{
    DIGSLogDebug_EnteringMethod();

    NSBeginAlertSheet(
        @"Invalid Dev Tools path",  // title
        @"OK",  // defaultButton
        nil,  // alternateButton
        nil,  // otherButton
        [_xcodeAppPathField window],  // docWindow
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
        performSelector:@selector(promptForXcodeLocation:)
        withObject:nil
        afterDelay:(NSTimeInterval)0.0
        inModes:
            [NSArray arrayWithObjects:
                NSDefaultRunLoopMode,
                NSModalPanelRunLoopMode,
                nil]];
}

@end
