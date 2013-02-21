/*
 * AKAppController.m
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKAppController.h"

#import <CoreFoundation/CoreFoundation.h>

#import "DIGSLog.h"
#import "DIGSFindBuffer.h"

#import "AKAboutWindowController.h"
#import "AKAppVersion.h"
#import "AKClassNode.h"
#import "AKDatabase.h"
#import "AKDatabaseXMLExporter.h"
#import "AKDevToolsPanelController.h"
#import "AKDocLocator.h"
#import "AKDocSetIndex.h"
#import "AKLoadDatabaseOperation.h"
#import "AKPrefPanelController.h"
#import "AKPrefUtils.h"
#import "AKQuicklistController.h"
#import "AKSavedWindowState.h"
#import "AKServicesProvider.h"
#import "AKSplashWindowController.h"
#import "AKTestDocParserWindowController.h"
#import "AKTopic.h"
#import "AKWindowController.h"
#import "AKWindowLayout.h"



// [agl] working on parse performance
#define MEASURE_PARSE_SPEED 1


#pragma mark -
#pragma mark Forwarding of applescript commands

// Thanks to Dominik Wagner for AppleScript support!

@interface NSApplication (NSAppScriptingAdditions)
- (id)handleSearchScriptCommand:(NSScriptCommand *)aCommand;
@end


@implementation NSApplication (NSAppScriptingAdditions)

- (id)handleSearchScriptCommand:(NSScriptCommand *)aCommand
{
    return [(AKAppController *)[NSApp delegate] handleSearchScriptCommand:aCommand];
}

@end


#pragma mark -

@implementation AKAppController

#pragma mark -
#pragma mark Init/awake/dealloc

// [agl] working on performance
#if MEASURE_PARSE_SPEED
static NSTimeInterval g_startTime = 0.0;
static NSTimeInterval g_checkpointTime = 0.0;

- (void)_timeParseStart
{
    g_startTime = [NSDate timeIntervalSinceReferenceDate];
    g_checkpointTime = g_startTime;
    NSLog(@"---------------------------------");
    NSLog(@"START: about to parse...");
}

- (void)_timeParseCheckpoint:(NSString *)description
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"...CHECKPOINT: %@", description);
    NSLog(@"               %.3f seconds since last checkpoint", now - g_checkpointTime);
    g_checkpointTime = now;
}

- (void)_timeParseEnd
{
    NSLog(@"...DONE: took %.3f seconds total", [NSDate timeIntervalSinceReferenceDate] - g_startTime);
}
#endif //MEASURE_PARSE_SPEED

- (id)init
{
    if ((self = [super init]))
    {
        _operationQueue = [[NSOperationQueue alloc] init];
        _finishedInitializing = NO;
        _windowControllers = [[NSMutableArray alloc] init];
        _favoritesList = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Application startup

- (void)startApplicationStartup
{
	// Try to create an AKDatabase instance. If we have problems doing so, the
    // user might opt to cancel launching the app.
    _appDatabase = [self _instantiateDatabase];
    if (_appDatabase == nil)
    {
        [NSApp terminate:nil];
    }
    DIGSLogDebug(@"dev tools path is [%@]", [AKPrefUtils devToolsPathPref]);

    // Put up the splash window.
    _splashWindowController = [[AKSplashWindowController alloc] initWithWindowNibName:@"SplashWindow"];
    [[_splashWindowController window] center];
    [[_splashWindowController window] makeKeyAndOrderFront:nil];

    // Start loading the database asynchronously while the splash window stays
    // on-screen. When the AKLoadDatabaseOperation finishes it will send us a
    // finishApplicationStartup message.
// [agl] working on performance
#if MEASURE_PARSE_SPEED
[self _timeParseStart];
#endif //MEASURE_PARSE_SPEED

    AKLoadDatabaseOperation *op = [[AKLoadDatabaseOperation alloc] init];

    [op setAppDatabase:_appDatabase];
    [op setDatabaseDelegate:_splashWindowController];
    [_operationQueue addOperation:op];
}

- (void)setSplashWindowController:(AKSplashWindowController *)wc
{
    _splashWindowController = wc;
}

- (void)finishApplicationStartup
{
// [agl] working on performance
#if MEASURE_PARSE_SPEED
[self _timeParseEnd];
#endif //MEASURE_PARSE_SPEED

    // Take down the splash window.
    [[_splashWindowController window] close];
    [self setSplashWindowController:nil];

    // Sanity-check the database we just loaded. If it's missing NSObject
    // documentation, the user probably has to download the docs.
    //
    // [agl] It would be nice to sanity-check the docset documentation *before*
    // spending all that time iterating through header files and docset files.
    // Xcode is clearly able to do it -- it knows whether to put an "Install"
    // button by the docset.
    //
    // I see nothing in the docset's Info.plist that indicates whether it's
    // downloaded. Purely guessing after browsing a few docsets, I notice that
    // downloaded docsets *don't* seem to have a version.plist file next to
    // Info.plist. But my sample size is too small to trust this as a reliable
    // indicator. It might be worth asking the Apple docs people, or the answer
    // might even be documented somewhere.
    //
    // One solution might be to query the sqlite database for the location of
    // the NSObject class doc, and see if that file exists.
    //
    // Maybe someday this won't be a problem any more because I'll able to
    // assume all downloaded docsets are in ~/Library/Developer.
    //
    // I'm going with the current solution purely because it's quick to
    // implement. I can revisit when I have more time.
    AKClassNode *nsObjectNode = [_appDatabase classWithName:@"NSObject"];

    if ([nsObjectNode nodeDocumentation] == nil)
    {
        NSString *alertText = [NSString stringWithFormat:(@"The selected docset is missing HTML files.\n\n"
                                                          @"You can tell Xcode to download the docset by going to Xcode > Preferences > Downloads > Documentation.\n\n"
                                                          @"Alternatively, you can try selecting a different SDK."
                                                          )];
        NSAlert *alert = [NSAlert alertWithMessageText:@"Missing HTML files"
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"%@", alertText];
        [alert runModal];

        if (![[AKDevToolsPanelController controller] runDevToolsSetupPanel])
        {
            [NSApp terminate:nil];
        }
        
        [self performSelector:@selector(startApplicationStartup) withObject:nil afterDelay:0];
        
        return;
    }
    
    // Finish initializing the UI.
    [self _initGoMenu];
    [self _getFavoritesFromPrefs];

    // Register interest in window-close events.
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(_handleWindowWillCloseNotification:)
        name:NSWindowWillCloseNotification
        object:nil];

    // Force the DIGSFindBuffer to initialize.
    // [agl] ??? Why not in DIGSFindBuffer's +initialize?
    (void)[DIGSFindBuffer sharedInstance];

    // Reopen windows from the previous session.
    [self _openInitialWindows];

    // Add the Debug menu if certain conditions are met.
    [self _maybeAddDebugMenu];
    
    // Set the provider of system services.
    [NSApp setServicesProvider:[[AKServicesProvider alloc] init]];
    NSUpdateDynamicServices();

    _finishedInitializing = YES;
}


#pragma mark -
#pragma mark Getters and setters

- (AKDatabase *)appDatabase
{
    return _appDatabase;
}


#pragma mark -
#pragma mark Navigation

// [agl] what about using [NSView +focusView]?
- (NSTextView *)selectedTextView
{
    id obj = [[NSApp keyWindow] firstResponder];

    return (obj && [obj isKindOfClass:[NSTextView class]]) ? obj : nil;
}

- (AKWindowController *)frontmostWindowController
{
    return (AKWindowController *)[[self _frontmostBrowserWindow] delegate];
}

- (AKWindowController *)controllerForNewWindow
{
    // Create the window, using remembered prefs for its layout if any.
    NSDictionary *prefDict = [AKPrefUtils dictionaryValueForPref:AKLayoutForNewWindowsPrefName];
    AKWindowLayout *windowLayout = [AKWindowLayout fromPrefDictionary:prefDict];
    AKWindowController *windowController = [self _windowControllerForNewWindowWithLayout:windowLayout];

    // Stagger the window relative to the frontmost window, if there is one.
    NSWindow *existingWindow = [self _frontmostBrowserWindow];

    if (existingWindow)
    {
        NSRect existingFrame = [existingWindow frame];
        NSRect newFrame = [[windowController window] frame];

        newFrame = NSOffsetRect(newFrame,
                                NSMinX(existingFrame) - NSMinX(newFrame) + 20,
                                NSMaxY(existingFrame) - NSMaxY(newFrame) - 20);
        [[windowController window] setFrame:newFrame display:NO];
    }

    // Display the window.
    [windowController openWindowWithQuicklistDrawer:(windowLayout ? [windowLayout quicklistDrawerIsOpen] : YES)];

    return windowController;
}


#pragma mark -
#pragma mark Preferences

- (void)applyUserPreferences
{
    // Apply the newly saved preferences to all open windows.
    NSEnumerator *en = [_windowControllers objectEnumerator];
    AKWindowController *wc;

    while ((wc = [en nextObject]))
    {
        if (![wc isKindOfClass:[AKWindowController class]])
        {
            DIGSLogError(@"_windowControllers contains a non-AKWindowController");
        }
        else
        {
            [wc applyUserPreferences];
        }
    }
}


#pragma mark -
#pragma mark External search requests

- (void)searchForString:(NSString *)searchString
{
    if ([searchString length] == 0)
    {
        return;
    }
    
    AKWindowController *wc = nil;
    
    if (![AKPrefUtils shouldSearchInNewWindow])
    {
        wc = [self frontmostWindowController];
    }
    
    if (wc == nil)
    {
        wc = [self controllerForNewWindow];
    }
    
    [wc searchForString:searchString];
}


#pragma mark -
#pragma mark AppleScript support

- (id)handleSearchScriptCommand:(NSScriptCommand *)aCommand
{
    [self searchForString:[aCommand directParameter]];
    return nil;
}


#pragma mark -
#pragma mark Managing the user's Favorites list

- (NSArray *)favoritesList
{
    return _favoritesList;
}

- (void)addFavorite:(AKDocLocator *)docLocator
{
    // Only add the item if it's not already there.
    if ((docLocator != nil) && ![_favoritesList containsObject:docLocator])
    {
        [_favoritesList addObject:docLocator];
        [self _putFavoritesIntoPrefs];
        [self applyUserPreferences];
    }
}

- (void)removeFavoriteAtIndex:(NSInteger)favoritesIndex
{
    if (favoritesIndex >= 0)
    {
        [_favoritesList removeObjectAtIndex:favoritesIndex];
        [self _putFavoritesIntoPrefs];
        [self applyUserPreferences];
    }
}

- (void)moveFavoriteFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    AKDocLocator *fav = [_favoritesList objectAtIndex:fromIndex];

    if (fromIndex > toIndex)
    {
        [_favoritesList removeObjectAtIndex:fromIndex];
        [_favoritesList insertObject:fav atIndex:toIndex];
    }
    else
    {
        [_favoritesList insertObject:fav atIndex:toIndex];
        [_favoritesList removeObjectAtIndex:fromIndex];
    }
    [self _putFavoritesIntoPrefs];
    [self applyUserPreferences];
}


#pragma mark -
#pragma mark Action methods

- (IBAction)openAboutPanel:(id)sender
{
    if (_aboutWindowController == nil)
    {
        _aboutWindowController = [[AKAboutWindowController alloc] initWithWindowNibName:@"AboutWindow"];
    }
    
    [[_aboutWindowController window] center];
    [[_aboutWindowController window] makeKeyAndOrderFront:nil];
}

- (IBAction)checkForNewerVersion:(id)sender
{
    // Phone home for the latest version number.
    AKAppVersion *latestVersion = [self _latestAppVersion];

    if (latestVersion == nil)
    {
        return;
    }

    // See if the latest version is newer than what the user is running.
    AKAppVersion *thisVersion = [AKAppVersion appVersion];

    if (![latestVersion isNewerThanVersion:thisVersion])
    {
        NSRunAlertPanel(
            @"Up to date",  // title
            @"You have the latest version of AppKiDo.",  // msg
            @"OK",  // defaultButton
            nil,  // alternateButton
            nil);  // otherButton

        return;
    }

    // If we got this far, the user does not have the latest version.
    NSString *alertMessage =
        [NSString
            stringWithFormat:
                @"Version %@ of AppKiDo is available for download."
                @"  You are currently running version %@."
                @"\n\nWould you like to go to the AppKiDo web page?",
            [latestVersion displayString],
            [thisVersion displayString]];

    NSInteger whichButton =
        NSRunAlertPanel(
            @"Newer version available",  // title
            alertMessage,  // msg
            @"Yes, go to web site",  // defaultButton
            nil,  // alternateButton
            @"No");  // otherButton

    if (whichButton == NSAlertDefaultReturn)
    {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:AKHomePageURL]];
    }
}

- (IBAction)openPrefsPanel:(id)sender
{
    if (_prefPanelController == nil)
    {
        _prefPanelController = [[AKPrefPanelController alloc] init];
        [NSBundle loadNibNamed:@"Prefs" owner:_prefPanelController];
    }

    [_prefPanelController openPrefsPanel:sender];
}

- (IBAction)openNewWindow:(id)sender
{
    (void)[self controllerForNewWindow];
}

// This is only called from the doc view's contextual menu, so it's
// not declared in the .h.
- (IBAction)openLinkInNewWindow:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]])
    {
        NSURL *linkURL = (NSURL *)[sender representedObject];
        AKWindowController *wc = [self controllerForNewWindow];

        (void)[wc jumpToLinkURL:linkURL];
    }
}

- (IBAction)scrollToTextSelection:(id)sender
{
    NSTextView *textView = [self selectedTextView];

    if (textView)
    {
        [textView scrollRangeToVisible:[textView selectedRange]];
    }
}

- (IBAction)exportDatabase:(id)sender
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    NSString *defaultFilename = [NSString stringWithFormat:@"AppKiDo-DB-%@.xml", [AKAppVersion appVersion]];

    NSInteger modalResult = [savePanel runModalForDirectory:NSHomeDirectory() file:defaultFilename];

    if (modalResult != NSFileHandlingPanelOKButton)
    {
        return;
    }

    BOOL fileOK = [[NSFileManager defaultManager] createFileAtPath:[savePanel filename] contents:nil attributes:nil];

    if (!fileOK)
    {
        DIGSLogError_ExitingMethodPrematurely(
            ([NSString stringWithFormat:@"failed to get create file at [%@]", [savePanel filename]]));
        return;
    }

    AKDatabaseXMLExporter *exporter =
        [[AKDatabaseXMLExporter alloc] initWithDatabase:_appDatabase fileURL:[savePanel URL]];
    [exporter doExport];
}

#pragma mark -
#pragma mark Action methods for debugging only

- (IBAction)_testParser:(id)sender
{
    [AKTestDocParserWindowController openNewParserWindow];
}

- (IBAction)_printKeyViewLoop:(id)sender
{
    id firstResponder = [[NSApp keyWindow] firstResponder];

    if (firstResponder == nil)
    {
        NSLog(@"there's no first responder");
    }
    else
    {
        NSLog(@"key window's first responder is %@ at %p", [firstResponder className], firstResponder);

        if ([firstResponder isKindOfClass:[NSView class]])
        {
            [firstResponder ak_printKeyViewLoop];
            [firstResponder ak_printReverseKeyViewLoop];
        }
    }
}


#pragma mark -
#pragma mark UI item validation

- (BOOL)validateItem:(id)anItem
{
    SEL itemAction = [anItem action];

    if (itemAction == @selector(openSearchPanel:))
    {
        return YES;
    }
    else if ((itemAction == @selector(openNewWindow:))
        || (itemAction == @selector(openLinkInNewWindow:))
        || (itemAction == @selector(openPrefsPanel:))
        || (itemAction == @selector(checkForNewerVersion:))
        || (itemAction == @selector(openAboutPanel:))
        || (itemAction == @selector(exportDatabase:)))
    {
        return YES;
    }
    else if ((itemAction == @selector(_testParser:))
        || (itemAction == @selector(_printKeyViewLoop:)))
    {
        return YES;
    }
    else if (itemAction == @selector(scrollToTextSelection:))
    {
        NSTextView *tv = [self selectedTextView];

        if (tv == nil) { return NO; }

        return ([tv selectedRange].length > 0);
    }
    else
    {
        return NO;
    }
}


#pragma mark -
#pragma mark NSMenuValidation protocol methods

- (BOOL)validateMenuItem:(NSMenuItem *)aCell
{
    return [self validateItem:aCell];
}


#pragma mark -
#pragma mark NSToolbarItemValidation protocol methods

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    return [self validateItem:theItem];
}


#pragma mark -
#pragma mark NSApplication delegate methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self startApplicationStartup];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (!flag && _finishedInitializing)
    {
        (void)[self controllerForNewWindow];
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Update prefs with the state of all open windows.
    [AKPrefUtils setArrayValue:[self _allWindowsAsPrefArray] forPref:AKSavedWindowStatesPrefName];
}


#pragma mark -
#pragma mark Private methods -- steps during launch

- (AKDatabase *)_instantiateDatabase
{
    NSMutableArray *errorStrings = [NSMutableArray array];
    AKDatabase *dbToReturn = nil;

	while (1)
	{
		// Try to create a database instance.
        [errorStrings removeAllObjects];
#if APPKIDO_FOR_IPHONE
		dbToReturn = [AKDatabase databaseForIPhonePlatformWithErrorStrings:errorStrings];
#else
		dbToReturn = [AKDatabase databaseForMacPlatformWithErrorStrings:errorStrings];
#endif
		if (dbToReturn)
		{
            return dbToReturn;
        }

        // If we couldn't make a database instance, have the user re-specify the
        // Dev Tools info, and try again. Note that runDevToolsSetupPanel may
        // modify values for devToolsPathPref and sdkVersionPref (that's what
        // it's for).
//        [AKPrefUtils setDevToolsPathPref:nil];
        [AKPrefUtils setSDKVersionPref:nil];
        
        [self _displayDatabaseCreationErrorStrings:errorStrings];
        if (![[AKDevToolsPanelController controller] runDevToolsSetupPanel])
        {
            return nil;
        }
    }
}

- (void)_displayDatabaseCreationErrorStrings:(NSArray *)errorStrings
{
    NSString *alertText = [NSString stringWithFormat:(@"Try re-entering info about your Dev Tools setup.\n\n"
                                                      @"The gory details:\n\n%@"),
                           [errorStrings componentsJoinedByString:@"\n"]];
    NSAlert *alert = [NSAlert alertWithMessageText:@"Problem loading docs and/or SDK info"
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"%@", alertText];
    [alert runModal];
}

- (void)_initGoMenu
{
    DIGSLogDebug_EnteringMethod();

    NSMenu *goMenu = [_firstGoMenuDivider menu];
    NSInteger menuIndex = [goMenu indexOfItem:_firstGoMenuDivider];

    NSEnumerator *fwNameEnum = [[_appDatabase sortedFrameworkNames] objectEnumerator];
    NSString *fwName;

    while ((fwName = [fwNameEnum nextObject]))
    {
        // See what information we have for this framework.
        NSArray *formalProtocolNodes = [_appDatabase formalProtocolsForFrameworkNamed:fwName];
        NSArray *informalProtocolNodes = [_appDatabase informalProtocolsForFrameworkNamed:fwName];
        NSArray *functionsGroupNodes = [_appDatabase functionsGroupsForFrameworkNamed:fwName];
        NSArray *globalsGroupNodes = [_appDatabase globalsGroupsForFrameworkNamed:fwName];

        // Construct the submenu of framework-related topics.
        NSMenu *fwTopicSubmenu = [[NSMenu alloc] initWithTitle:fwName];

        if ([formalProtocolNodes count] > 0)
        {
            NSMenuItem *subitem =
                [[NSMenuItem alloc]
                    initWithTitle:AKProtocolsTopicName
                    action:@selector(jumpToFrameworkFormalProtocols:)
                    keyEquivalent:@""];

            [fwTopicSubmenu addItem:subitem];
        }

        if ([informalProtocolNodes count] > 0)
        {
            NSMenuItem *subitem =
                [[NSMenuItem alloc]
                    initWithTitle:AKInformalProtocolsTopicName
                    action:@selector(jumpToFrameworkInformalProtocols:)
                    keyEquivalent:@""];

            [fwTopicSubmenu addItem:subitem];
        }

        if ([functionsGroupNodes count] > 0)
        {
            NSMenuItem *subitem =
                [[NSMenuItem alloc]
                    initWithTitle:AKFunctionsTopicName
                    action:@selector(jumpToFrameworkFunctions:)
                    keyEquivalent:@""];

            [fwTopicSubmenu addItem:subitem];
        }

        if ([globalsGroupNodes count] > 0)
        {
            NSMenuItem *subitem =
                [[NSMenuItem alloc]
                    initWithTitle:AKGlobalsTopicName
                    action:@selector(jumpToFrameworkGlobals:)
                    keyEquivalent:@""];

            [fwTopicSubmenu addItem:subitem];
        }

        // Construct the menu item to add to the Go menu, and add it.
        NSMenuItem *fwMenuItem =
            [[NSMenuItem alloc]
                initWithTitle:fwName
                action:nil
                keyEquivalent:@""];

        [fwMenuItem setSubmenu:fwTopicSubmenu];
        menuIndex++;
        [goMenu insertItem:fwMenuItem atIndex:menuIndex];
    }
}

// Add the Debug menu if the user is "Andy Lee" with login name "alee".
- (void)_maybeAddDebugMenu
{
    DIGSLogDebug_EnteringMethod();
    
    if ([NSUserName() isEqualToString:@"alee"] && [NSFullUserName() isEqualToString:@"Andy Lee"])
    {
        // Create the "Debug" top-level menu item.
        NSMenu *mainMenu = [NSApp mainMenu];
        NSMenuItem *debugMenuItem =
            [mainMenu addItemWithTitle:@"Debug" action:@selector(_testParser:) keyEquivalent:@""];
        [debugMenuItem setEnabled:YES];

        // Create the submenu that will be under the "Debug" top-level menu item.
        NSMenu *debugSubmenu = [[NSMenu alloc] initWithTitle:@"Debug"];

        [debugSubmenu setAutoenablesItems:YES];
        [debugSubmenu addItemWithTitle:@"Open Parser Testing Window" action:@selector(_testParser:) keyEquivalent:@""];
        [debugSubmenu addItemWithTitle:@"Print Key View Loop" action:@selector(_printKeyViewLoop:) keyEquivalent:@""];

        // Attach the submenu to the "Debug" top-level menu item.
        [mainMenu setSubmenu:debugSubmenu forItem:debugMenuItem];
    }
}


#pragma mark -
#pragma mark Private methods -- window management

- (NSWindow *)_frontmostBrowserWindow
{
    NSInteger numWindows;

    NSCountWindows(&numWindows);

    NSInteger windowList[numWindows];

    NSWindowList(numWindows, windowList);

    int i;
    for (i = 0; i < numWindows; i++)
    {
        NSInteger windowNum = windowList[i];
        NSWindow *win = [NSApp windowWithWindowNumber:windowNum];
        id del = [win delegate];

        if ([del isKindOfClass:[AKWindowController class]])
        {
            return win;
        }
    }

    // If we got this far, there is no browser window open.
    return nil;
}

- (AKWindowController *)_windowControllerForNewWindowWithLayout:(AKWindowLayout *)windowLayout
{
    AKWindowController *windowController = [[AKWindowController alloc] initWithDatabase:_appDatabase];

    [_windowControllers addObject:windowController];
    if (windowLayout)
    {
        [windowController takeWindowLayoutFrom:windowLayout];
    }

    return windowController;
}

- (void)_handleWindowWillCloseNotification:(NSNotification *)notification
{
    id windowDelegate = [(NSWindow *)[notification object] delegate];

    if ([windowDelegate isKindOfClass:[AKWindowController class]])
    {
        [_windowControllers removeObjectIdenticalTo:windowDelegate];
    }
}

- (void)_openInitialWindows
{
    NSArray *savedWindows = [AKPrefUtils arrayValueForPref:AKSavedWindowStatesPrefName];

    if ([savedWindows count] == 0)
    {
        (void)[self controllerForNewWindow];
    }
    else
    {
        NSInteger numWindows = [savedWindows count];
        NSInteger i;

        for (i = numWindows - 1; i >= 0; i--)
        {
            NSDictionary *prefDict = [savedWindows objectAtIndex:i];
            AKSavedWindowState *savedWindowState = [AKSavedWindowState fromPrefDictionary:prefDict];
            AKWindowLayout *windowLayout = [savedWindowState savedWindowLayout];
            AKWindowController *wc = [self _windowControllerForNewWindowWithLayout:windowLayout];

            [wc jumpToDocLocator:[savedWindowState savedDocLocator]];
            [wc openWindowWithQuicklistDrawer:[[savedWindowState savedWindowLayout] quicklistDrawerIsOpen]];
        }
    }
}

// takes snapshot of all open windows, returns array of dictionaries
// suitable for NSUserDefaults
- (NSArray *)_allWindowsAsPrefArray
{
    NSMutableArray *result = [NSMutableArray array];
    NSInteger numWindows;

    NSCountWindows(&numWindows);

    NSInteger windowList[numWindows];

    NSWindowList(numWindows, windowList);

    NSInteger i;
    for (i = 0; i < numWindows; i++)
    {
        NSInteger windowNum = windowList[i];
        NSWindow *win = [NSApp windowWithWindowNumber:windowNum];
        id del = [win delegate];

        if ([del isKindOfClass:[AKWindowController class]])
        {
            AKWindowController *wc = (AKWindowController *)del;
            AKSavedWindowState *savedWindowState = [[AKSavedWindowState alloc] init];

            [wc putSavedWindowStateInto:savedWindowState];
            [result addObject:[savedWindowState asPrefDictionary]];
        }
    }

    return result;
}


#pragma mark -
#pragma mark Private methods -- version management

// URL of the file from which to get the latest version number.
#if APPKIDO_FOR_IPHONE
static NSString *_AKVersionURL = @"http://appkido.com/AppKiDo-for-iPhone.version";
#else
static NSString *_AKVersionURL = @"http://appkido.com/AppKiDo.version";
#endif

- (AKAppVersion *)_latestAppVersion
{
    NSURL *latestAppVersionURL = [NSURL URLWithString:_AKVersionURL];
    NSString *latestAppVersionString = [[NSString stringWithContentsOfURL:latestAppVersionURL
                                                                 encoding:NSUTF8StringEncoding
                                                                    error:NULL] ak_trimWhitespace];
    
    if (latestAppVersionString == nil)
    {
        NSRunAlertPanel(@"Problem phoning home",  // title
                        @"Couldn't access the version number from the"
                        @" AppKiDo web site.",  // msg
                        @"OK",  // defaultButton
                        nil,  // alternateButton
                        nil);  // otherButton
        
        return nil;
    }
    
    NSString *expectedPrefix = @"AppKiDoVersion";
    
    if ((![latestAppVersionString hasPrefix:expectedPrefix])
        || ([latestAppVersionString length] > 30))
    {
        DIGSLogWarning(@"the received contents of the version-number URL don't"
                       @" look like a valid version string");
        return nil;
    }
    
    latestAppVersionString = [latestAppVersionString substringFromIndex:[expectedPrefix length]];
    
    return [AKAppVersion appVersionFromString:latestAppVersionString];
}


#pragma mark -
#pragma mark Private methods -- Favorites

- (void)_getFavoritesFromPrefs
{
    DIGSLogDebug_EnteringMethod();
    
    NSArray *favPrefList = [AKPrefUtils arrayValueForPref:AKFavoritesPrefName];
    NSInteger numFavs = [favPrefList count];
    NSInteger i;

    // Get values from NSUserDefaults.
    [_favoritesList removeAllObjects];
    BOOL someFavsWereInvalid = NO;
    for (i = 0; i < numFavs; i++)
    {
        id favPref = [favPrefList objectAtIndex:i];
        AKDocLocator *favItem = [AKDocLocator fromPrefDictionary:favPref];

        // It is possible for a Favorite to be invalid if the user has
        // chosen to exclude the framework the Favorite belongs to.
        if ([favItem stringToDisplayInLists])
        {
            [_favoritesList addObject:favItem];
        }
        else
        {
            someFavsWereInvalid = YES;
        }
    }
    if (someFavsWereInvalid)
    {
        [self _putFavoritesIntoPrefs];
    }

    // Update the Favorites menu.
    [self _updateFavoritesMenu];
}

- (void)_putFavoritesIntoPrefs
{
    NSMutableArray *favPrefList = [NSMutableArray array];
    NSInteger numFavs = [_favoritesList count];
    NSInteger i;

    // Update the UserDefaults.
    for (i = 0; i < numFavs; i++)
    {
        AKDocLocator *favItem = [_favoritesList objectAtIndex:i];

        [favPrefList addObject:[favItem asPrefDictionary]];
    }
    [AKPrefUtils setArrayValue:favPrefList forPref:AKFavoritesPrefName];

    // Update the Favorites menu.
    [self _updateFavoritesMenu];
}

- (void)_updateFavoritesMenu
{
    NSMenu *mainMenu = [NSApp mainMenu];
    NSMenu *favoritesMenu = [[mainMenu itemWithTitle:@"Favorites"] submenu];
    NSInteger numFavs = [_favoritesList count];
    NSInteger i;

    while ([favoritesMenu numberOfItems] > 2)
    {
        [favoritesMenu removeItemAtIndex:2];
    }

    for (i = 0; i < numFavs; i++)
    {
        AKDocLocator *favItem = [_favoritesList objectAtIndex:i];
        NSMenuItem *menuItem =
            [[NSMenuItem alloc]
                initWithTitle:[favItem stringToDisplayInLists]
                action:@selector(jumpToDocLocatorRepresentedBy:)
                keyEquivalent:@""];

        if (i < 9)
        {
            [menuItem setKeyEquivalent:[NSString stringWithFormat:@"%ld", (long)(i + 1)]];
            [menuItem setKeyEquivalentModifierMask:NSControlKeyMask];
        }

        [menuItem setRepresentedObject:favItem];
        [favoritesMenu addItem:menuItem];
    }
}

@end
