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
    [self _updateUIToReflectPrefs];
}


#pragma mark -
#pragma mark Action methods

- (IBAction)promptForXcodeLocation:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];

    // Even though a .app bundle is a directory and not a file, we pretend
    // otherwise when setting up the open panel.
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

- (void)_displaySearchPathsForDevTools:(AKDevTools *)devTools
{
    NSMutableString *explanationString = [NSMutableString string];

    [explanationString appendFormat:@"Search paths for docsets: %@.\n\n",
     [[devTools docSetSearchPaths] componentsJoinedByString:@", "]];
    [explanationString appendFormat:@"Search path for SDKs: %@.\n\n", [devTools sdkSearchPath]];

    [_explanationField setStringValue:explanationString];
}

- (void)_updateUIToReflectPrefs
{
    NSString *devToolsPath = [AKPrefUtils devToolsPathPref];
#if APPKIDO_FOR_IPHONE
    AKIPhoneDevTools *devTools = [AKIPhoneDevTools devToolsWithPath:devToolsPath];
#else
    AKMacDevTools *devTools = [AKMacDevTools devToolsWithPath:devToolsPath];
#endif
    NSArray *sdkVersionsToOffer = [devTools sdkVersionsThatAreCoveredByDocSets];

    // Populate the SDK versions popup.
    [_sdkVersionsPopUpButton removeAllItems];
    for (NSString *sdkVersion in sdkVersionsToOffer)
    {
        [_sdkVersionsPopUpButton addItemWithTitle:sdkVersion];
    }
    
    // Select the appropriate item in the SDK versions popup.
    NSString *selectedSDKVersion = [AKPrefUtils sdkVersionPref];
    if ((selectedSDKVersion == nil)
        || ([devTools docSetSDKVersionThatCoversSDKVersion:selectedSDKVersion] == nil))
    {
        selectedSDKVersion = [sdkVersionsToOffer lastObject];
        [AKPrefUtils setSDKVersionPref:selectedSDKVersion];
    }
    [_sdkVersionsPopUpButton selectItemWithTitle:selectedSDKVersion];
    
    // Update the text that tells where we searched for docsets and SDKs.
    [self _displaySearchPathsForDevTools:devTools];
    
    // Update the enabledness of the OK button.
    [_okButton setEnabled:(selectedSDKVersion != nil)];
}

// Called when the open panel sheet opened by -promptForXcodeLocation: is dismissed.
- (void)_xcodeOpenPanelDidEnd:(NSOpenPanel *)panel
    returnCode:(int)returnCode
    contextInfo:(void *)contextInfo
{
    [self autorelease];  // was retained by -promptForXcodeLocation:

    if (returnCode == NSOKButton)
    {
        NSString *proposedXcodeAppPath = [[[panel URLs] lastObject] path];
        NSString *devToolsPath = [AKDevToolsUtils devToolsPathFromPossibleXcodePath:proposedXcodeAppPath];
        NSMutableArray *errorStrings = [NSMutableArray array];

        [self _setSelectedXcodeAppPath:proposedXcodeAppPath];

        if ([AKDevTools looksLikeValidDevToolsPath:devToolsPath errorStrings:errorStrings])
        {
            [_xcodeAppPathField setStringValue:proposedXcodeAppPath];
            [AKPrefUtils setDevToolsPathPref:devToolsPath];
            [self _updateUIToReflectPrefs];
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

- (void)_showBadPathAlert:(NSString *)errorMessage
{
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

- (void)_badPathAlertDidEnd:(NSOpenPanel *)panel
    returnCode:(int)returnCode
    contextInfo:(void *)contextInfo
{
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
