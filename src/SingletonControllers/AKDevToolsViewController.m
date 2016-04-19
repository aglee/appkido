//
//  AKDevToolsPrefsViewController.m
//  AppKiDo
//
//  Created by Andy Lee on 6/17/08.
//  Copyright 2008 Andy Lee. All rights reserved.
//

#import "AKDevToolsViewController.h"

#import "DIGSLog.h"
#import "AKDevToolsUtils.h"
#import "AKIPhoneDevTools.h"
#import "AKMacDevTools.h"
#import "AKPrefUtils.h"

@implementation AKDevToolsViewController

@synthesize xcodeAppPathField = _xcodeAppPathField;
@synthesize locateXcodeButton = _locateXcodeButton;
@synthesize sdkVersionsPopUpButton = _sdkVersionsPopUpButton;
@synthesize explanationField = _explanationField;
@synthesize okButton = _okButton;

#pragma mark -
#pragma mark Init/awake/dealloc

- (void)awakeFromNib
{
    NSString *devToolsPath = [AKPrefUtils devToolsPathPref];
    NSString *xcodeAppPath = [AKDevToolsUtils xcodeAppPathFromDevToolsPath:devToolsPath];

    [self _setSelectedXcodeAppPath:xcodeAppPath];
    
    // Populate the UI with initial values.
    if (xcodeAppPath)
    {
        [_xcodeAppPathField setStringValue:xcodeAppPath];
    }
    else
    {
        [_xcodeAppPathField setStringValue:@""];
    }
    
    [self _updateUIToReflectPrefs];
}


#pragma mark -
#pragma mark Getters and setters

- (void)setOkButton:(NSButton *)okButton
{
    _okButton = okButton;

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

    if (_selectedXcodeAppPath) {
        [openPanel setDirectoryURL:[NSURL fileURLWithPath:_selectedXcodeAppPath]];
    } else {
        NSURL *appDirURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationDirectory inDomains:NSSystemDomainMask] lastObject];
        if (appDirURL) {
            [openPanel setDirectoryURL:appDirURL];
        }
    }
    [openPanel setAllowedFileTypes:@[@"app"]];
    
    [openPanel beginSheetModalForWindow:[_xcodeAppPathField window]
                      completionHandler:^(NSInteger result) {
                          if (result == NSFileHandlingPanelOKButton)
                          {
                              [self _handleProposedXcodeAppPath:[[openPanel URL] path]];
                          }
                      }];
}

- (IBAction)selectSDKVersion:(id)sender
{
    [AKPrefUtils setSDKVersionPref:[[(NSPopUpButton *)sender selectedItem] title]];
    [self _updateUIToReflectPrefs];
}

#pragma mark -
#pragma mark NSOpenSavePanelDelegate methods

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
    _selectedXcodeAppPath = [xcodeAppPath copy];
}

- (NSString *)_infoTextForDevTools:(AKDevTools *)devTools
                selectedSDKVersion:(NSString *)selectedSDKVersion
                  docSetSDKVersion:(NSString *)docSetSDKVersion
{
    if (selectedSDKVersion == nil)
    {
        return @"";
    }

    NSMutableString *infoText = [NSMutableString string];
    NSString *sdkPath = [devTools sdkPathForSDKVersion:selectedSDKVersion];

    if (sdkPath == nil)
    {
        [infoText appendFormat:@"No %@ SDK was found in %@.", selectedSDKVersion, [devTools devToolsPath]];
    }
    else
    {
        [infoText appendFormat:@"The selected SDK is installed at %@.\n\n", sdkPath];

        NSString *docSetPath = [devTools docSetPathForSDKVersion:docSetSDKVersion];

        if (docSetPath == nil)
        {
            [infoText appendFormat:@"No docset was found in %@ that covers the %@ SDK.",
             [devTools devToolsPath], selectedSDKVersion];
        }
        else
        {
            [infoText appendFormat:@"This SDK is covered by the %@ docset at %@.",
             docSetSDKVersion, docSetPath];
        }
    }

    return infoText;
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
    NSString *docSetSDKVersion = [devTools docSetSDKVersionThatCoversSDKVersion:selectedSDKVersion];
    
    if ((selectedSDKVersion == nil) || (docSetSDKVersion == nil))
    {
        selectedSDKVersion = [sdkVersionsToOffer lastObject];
        docSetSDKVersion = [devTools docSetSDKVersionThatCoversSDKVersion:selectedSDKVersion];
        
        [AKPrefUtils setSDKVersionPref:selectedSDKVersion];
    }
    [_sdkVersionsPopUpButton selectItemWithTitle:selectedSDKVersion];
    
    // Update the info text.
    NSString *infoText = [self _infoTextForDevTools:devTools
                                 selectedSDKVersion:selectedSDKVersion
                                   docSetSDKVersion:docSetSDKVersion];
    [_explanationField setStringValue:infoText];
    
    // Update the enabledness of the OK button.
    [_okButton setEnabled:(selectedSDKVersion != nil)];
}

- (void)_handleProposedXcodeAppPath:(NSString *)proposedXcodeAppPath
{
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
        [self performSelector:@selector(_showBadPathAlert:)
                   withObject:errorMessage
                   afterDelay:(NSTimeInterval)0.0
                      inModes:(@[
                               NSDefaultRunLoopMode,
                               NSModalPanelRunLoopMode,
                               ])];
    }
}

- (void)_showBadPathAlert:(NSString *)errorMessage
{
    NSBeginAlertSheet(@"Invalid Dev Tools path",  // title
                      @"OK",  // defaultButton
                      nil,  // alternateButton
                      nil,  // otherButton
                      [_xcodeAppPathField window],  // docWindow
                      self,  // modalDelegate -- will release when alert ends
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
    [self performSelector:@selector(promptForXcodeLocation:)
               withObject:nil
               afterDelay:(NSTimeInterval)0.0
                  inModes:(@[
                           NSDefaultRunLoopMode,
                           NSModalPanelRunLoopMode,
                           ])];
}

@end
