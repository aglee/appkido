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

@implementation AKDevToolsPathController

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)controllerWithTextField:(NSTextField *)textField
{
    return [[[self alloc] initWithTextField:textField] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithTextField:(NSTextField *)textField
{
    if ((self = [super init]))
    {
        _devToolsPathField = [textField retain];
    }

    return self;
}

- (id)init
{
    DIGSLogNondesignatedInitializer();
    [self release];
    return nil;
}

- (void)dealloc
{
    DIGSLogEnteringMethod();

    [_devToolsPathField release];

    [super dealloc];
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

- (void)runOpenPanel
{
    DIGSLogEnteringMethod();

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

//-------------------------------------------------------------------------
// Modal delegate methods and support for them
//-------------------------------------------------------------------------

// Called when the user has selected a (seemingly) valid Dev Tools path.
- (void)_acceptDevToolsPath:(NSString *)selectedDir
{
    DIGSLogObject(@"selectedDir", selectedDir);
    [_devToolsPathField setStringValue:selectedDir];
    [AKPrefUtils setDevToolsPathPref:selectedDir];
}

// Called by -_devToolsOpenPanelDidEnd:returnCode:contextInfo: if the user
// selects a directory that does not look like a valid Dev Tools directory.
- (void)_showBadPathAlert:(NSString *)selectedDir
{
    DIGSLogEnteringMethod();

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
    DIGSLogEnteringMethod();

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

// Weird, there's no -performSelector:afterDelay: (without a withObject:).
- (void)_runOpenPanel:(id)ignore
{
    [self runOpenPanel];
}

// Called when the alert sheet opened by -_showBadPathAlert is dismissed.
- (void)_badPathAlertDidEnd:(NSOpenPanel *)panel
    returnCode:(int)returnCode
    contextInfo:(void *)contextInfo
{
    DIGSLogEnteringMethod();

    [self autorelease];  // was retained by -_showBadPathAlert

    if (returnCode == NSOKButton)  // "OK" means try the open panel again
    {
        [self
            performSelector:@selector(_runOpenPanel:)
            withObject:nil
            afterDelay:(NSTimeInterval)0.0];
    }
}

@end