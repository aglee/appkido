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


// [agl] TODO Don't need this object around after user makes successful
// selection.

@implementation AKDevToolsPathController

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (AKDevToolsPathController *)controllerWithTextField:(NSTextField *)textField
{
    return [[[self alloc] initWithTextField:textField] autorelease];
}

+ (AKDevToolsPathController *)controllerWithNib
{
    return [[[self alloc] initWithNib] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

// Designated initializer.
- (id)init
{
    return [super init];
}

- (id)initWithTextField:(NSTextField *)textField
{
    if ((self = [self init]))
    {
        _devToolsPathField = [textField retain];
    }

    return self;
}

- (id)initWithNib
{
    if ((self = [self init]))
    {
        if (![NSBundle loadNibNamed:@"DevToolsPath" owner:self])
        {
            DIGSLogDebug(@"Failed to load DevToolsPath");
            [self release];
            return nil;
        }
    }

    return self;
}

- (void)dealloc
{
    [_devToolsPathField release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (void)runModalPromptWindow
{
    // [agl] FIXME fill this in
}

//-------------------------------------------------------------------------
// Running the panel
//-------------------------------------------------------------------------

+ (BOOL)_directory:(NSString *)dir hasSubdirectory:(NSString *)subdir
{
    BOOL subdirExists =
        [AKFileUtils
            directoryExistsAtPath:
                [dir stringByAppendingPathComponent:subdir]];

    if (!subdirExists)
    {
        DIGSLogDebug(
            @"%@ doesn't seem to be a valid Dev Tools path"
                " -- it doesn't have a subdirectory %@",
            dir, subdir);
    }

    return subdirExists;
}

+ (BOOL)looksLikeValidDevToolsPath:(NSString *)devToolsPath
{
    return
        [self _directory:devToolsPath hasSubdirectory:@"Applications/Xcode.app"]
        && [self _directory:devToolsPath hasSubdirectory:@"Documentation"]
        && [self _directory:devToolsPath hasSubdirectory:@"Examples"];
}

- (NSString *)promptForDevToolsPath:(NSString *)oldPath
{
    if (oldPath == nil)
    {
        [_devToolsPathField setStringValue:@""];
    }
    else
    {
        [_devToolsPathField setStringValue:oldPath];
    }

    NSInteger result =
        [[NSApplication sharedApplication]
            runModalForWindow:[_devToolsPathField window]];

    if (result == NSRunAbortedResponse)
    {
        return nil;
    }
    else
    {
        return [_devToolsPathField stringValue];
    }
}

//-------------------------------------------------------------------------
// Establishing the Dev Tools location
//-------------------------------------------------------------------------

- (void)runOpenPanel
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];

    [openPanel setPrompt:@"Select Dev Tools Location"];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setResolvesAliases:YES];
    
    [openPanel
        beginSheetForDirectory:[_devToolsPathField stringValue]
        file:nil
        types:nil
        modalForWindow:[_devToolsPathField window]
        modalDelegate:[self retain]  // will release when the open panel is dismissed
        didEndSelector:@selector(_devToolsOpenPanelDidEnd:returnCode:contextInfo:)
        contextInfo:(void *)NULL];
}

//-------------------------------------------------------------------------
// Action methods
//-------------------------------------------------------------------------

- (IBAction)runOpenPanel:(id)sender
{
    [self runOpenPanel];
}

- (IBAction)ok:(id)sender
{
    [[NSApplication sharedApplication] stopModal];
}

- (IBAction)cancel:(id)sender
{
    [[NSApplication sharedApplication] abortModal];
}

//-------------------------------------------------------------------------
// Modal delegate methods
//-------------------------------------------------------------------------

- (void)_devToolsOpenPanelDidEnd:(NSOpenPanel *)panel
    returnCode:(int)returnCode
    contextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton)
    {
        NSString *selectedDir = [panel directory];
NSLog(@"AKDevToolsPathController -- selectedDir: [%@]", selectedDir);  // [agl] REMOVE

//    [AKPrefUtils setDevToolsPathPref:selectedDir];

        if (![[self class] looksLikeValidDevToolsPath:selectedDir])
        {
            NSBeginAlertSheet(
                @"Invalid Dev Tools path",  // title
                @"OK",  // defaultButton
                @"Cancel",  // alternateButton
                nil,  // otherButton
                [_devToolsPathField window],  // docWindow
                [self retain],  // modalDelegate
                @selector(_badPathAlertDidEnd:returnCode:contextInfo:),  // didEndSelector
                (SEL)NULL,  // didDismissSelector,
                (void *)[selectedDir retain],  // contextInfo,
                @"'%@' doesn't look like a valid Dev Tools path.  Are you sure it's what you want?",  // msg
                selectedDir
            );
        }

        [_devToolsPathField setStringValue:selectedDir];
    }
}

- (void)_badPathAlertDidEnd:(NSOpenPanel *)panel
    returnCode:(int)returnCode
    contextInfo:(void *)contextInfo
{
//    [panel orderOut:nil];

    NSString *selectedDir = [(NSString *)contextInfo retain];

    if (returnCode == NSOKButton)
    {
        [_devToolsPathField setStringValue:selectedDir];
    }
    else
    {
        DIGSLogDebug(@"user said not to accept bogus-looking Dev Tools path [%@]", selectedDir);
    }

    [self release];  // was retained by -_devToolsOpenPanelDidEnd:returnCode:contextInfo:
}

@end
