/*
 * AKAppDelegate.m
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKAppDelegate.h"

#import <CoreFoundation/CoreFoundation.h>

#import "DIGSLog.h"
#import "DIGSFindBuffer.h"

#import "AKAboutWindowController.h"
#import "AKAppVersion.h"
#import "AKClassItem.h"
#import "AKDatabase.h"
#import "AKDatabaseXMLExporter.h"
#import "AKDebugging.h"
#import "AKDevToolsPanelController.h"
#import "AKDocLocator.h"
#import "AKFindPanelController.h"
#import "AKPopQuizWindowController.h"
#import "AKPrefPanelController.h"
#import "AKPrefUtils.h"
#import "AKQuicklistViewController.h"
#import "AKRandomSearch.h"
#import "AKSavedWindowState.h"
#import "AKServicesProvider.h"
#import "AKSplashWindowController.h"
#import "AKTopic.h"
#import "AKWindowController.h"
#import "AKWindowLayout.h"

#import "NSString+AppKiDo.h"

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
    return [[AKAppDelegate appDelegate] handleSearchScriptCommand:aCommand];
}

@end

#pragma mark -

@implementation AKAppDelegate

@synthesize firstGoMenuDivider = _firstGoMenuDivider;

#pragma mark -
#pragma mark Shared instance

+ (AKAppDelegate *)appDelegate
{
    return (AKAppDelegate *)NSApp.delegate;
}

#pragma mark -
#pragma mark Init/awake/dealloc

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

- (instancetype)init
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

#pragma mark -
#pragma mark Getters and setters

- (AKDatabase *)appDatabase
{
    return _appDatabase;
}

#pragma mark -
#pragma mark Navigation

- (NSTextView *)selectedTextView  //TODO: What about using [NSView +focusView]?
{
    id obj = NSApp.keyWindow.firstResponder;

    return (obj && [obj isKindOfClass:[NSTextView class]]) ? obj : nil;
}

- (AKWindowController *)frontmostWindowController
{
    return (AKWindowController *)[self _frontmostBrowserWindow].delegate;
}

- (AKWindowController *)controllerForNewWindow
{
    // Create the window, using remembered prefs for its layout if any.
    NSDictionary *prefDict = [AKPrefUtils dictionaryValueForPref:AKLayoutForNewWindowsPrefName];
    AKWindowLayout *windowLayout = [AKWindowLayout fromPrefDictionary:prefDict];
    AKWindowController *wc = [self _windowControllerForNewWindowWithLayout:windowLayout];

    // Stagger the window relative to the frontmost window, if there is one.
    NSWindow *existingWindow = [self _frontmostBrowserWindow];

    if (existingWindow)
    {
        NSRect existingFrame = existingWindow.frame;
        NSRect newFrame = wc.window.frame;

        newFrame = NSOffsetRect(newFrame,
                                NSMinX(existingFrame) - NSMinX(newFrame) + 20,
                                NSMaxY(existingFrame) - NSMaxY(newFrame) - 20);
        [wc.window setFrame:newFrame display:NO];
    }

    // Display the window.
    [wc showWindow:nil];

    if ((windowLayout == nil) || windowLayout.quicklistDrawerIsOpen)
    {
        [wc openQuicklistDrawer];
    }

    return wc;
}

#pragma mark -
#pragma mark Search

- (void)performExternallyRequestedSearchForString:(NSString *)searchString
{
    if ([searchString ak_trimWhitespace].length == 0)
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
    [self performExternallyRequestedSearchForString:aCommand.directParameter];
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
    AKDocLocator *fav = _favoritesList[fromIndex];

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
    
    [_aboutWindowController.window center];
    [_aboutWindowController.window makeKeyAndOrderFront:nil];
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
        NSRunAlertPanel(@"Up to date",  // title
                        @"You have the latest version of AppKiDo.",  // msg
                        @"OK",  // defaultButton
                        nil,  // alternateButton
                        nil);  // otherButton

        return;
    }

    // If we got this far, the user does not have the latest version.
    NSString *alertMessage = [NSString stringWithFormat:(@"Version %@ of AppKiDo is available for download."
                                                         @"  You are currently running version %@."
                                                         @"\n\nWould you like to go to the AppKiDo web page?"),
                              [latestVersion displayString],
                              [thisVersion displayString]];
    //  fritza@mac.com 13-May-2014
    //  An annoying, spurious warning on a computed format string.
    //  Suppress it.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-security"
    NSInteger whichButton = NSRunAlertPanel(@"Newer version available",  // title
                                            alertMessage,  // msg
                                            @"Yes, go to web site",  // defaultButton
                                            nil,  // alternateButton
                                            @"No");  // otherButton
#pragma clang diagnostic pop
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

- (IBAction)openLinkInNewWindow:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]])
    {
        NSURL *linkURL = (NSURL *)[sender representedObject];
        AKWindowController *wc = [self controllerForNewWindow];

        (void)[wc followLinkURL:linkURL];
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

    savePanel.allowedFileTypes = @[ @"xml" ];
    [savePanel setAllowsOtherFileTypes:YES];
    [savePanel setCanCreateDirectories:YES];
    [savePanel setCanSelectHiddenExtension:YES];

    if ([savePanel runModal] != NSFileHandlingPanelOKButton)
    {
        return;
    }

    BOOL fileOK = [[NSFileManager defaultManager] createFileAtPath:savePanel.URL.path
                                                          contents:nil
                                                        attributes:nil];
    if (!fileOK)
    {
        DIGSLogError_ExitingMethodPrematurely(([NSString stringWithFormat:@"failed to get create file at [%@]",
                                                [[savePanel URL] path]]));
        return;
    }

    AKDatabaseXMLExporter *exporter = [[AKDatabaseXMLExporter alloc] initWithDatabase:_appDatabase
                                                                               fileURL:savePanel.URL];
    [exporter doExport];
}

- (IBAction)popQuiz:(id)sender
{
    [AKPopQuizWindowController showPopQuiz];
}

#pragma mark -
#pragma mark AKUIController methods

- (void)applyUserPreferences
{
    // Apply the newly saved preferences to all open windows.
    for (AKWindowController *wc in _windowControllers)
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

- (void)takeWindowLayoutFrom:(AKWindowLayout *)windowLayout
{
}

- (void)putWindowLayoutInto:(AKWindowLayout *)windowLayout
{
}

#pragma mark -
#pragma mark NSUserInterfaceValidations methods

- (BOOL)validateUserInterfaceItem:(id)anItem
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
             || (itemAction == @selector(exportDatabase:))
             || (itemAction == @selector(popQuiz:)))
    {
        return YES;
    }
    else if (itemAction == @selector(scrollToTextSelection:))
    {
        NSTextView *tv = [self selectedTextView];

        if (tv == nil) { return NO; }

        return ([tv selectedRange].length > 0);
    }
    
    return NO;
}

#pragma mark -
#pragma mark NSApplication delegate methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Create the AKDatabase instance or bust.
    NSString *docSetBundlePath = [@"~/Library/Developer/Shared/Documentation/DocSets/com.apple.adc.documentation.OSX.docset/" stringByExpandingTildeInPath];  //FIXME: REMOVE DEBUGGING
    DocSetIndex *docSetIndex = [[DocSetIndex alloc] initWithDocSetPath:docSetBundlePath];
    _appDatabase = [[AKDatabase alloc] initWithDocSetIndex:docSetIndex];
    if (_appDatabase == nil)
    {
        [NSApp terminate:nil];
    }
    DIGSLogDebug(@"dev tools path is [%@]", [AKPrefUtils devToolsPathPref]);

    // Put up the splash window, which will show progress as we populate the database.
    _splashWindowController = [[AKSplashWindowController alloc] initWithWindowNibName:@"SplashWindow"];
    [_splashWindowController.window center];
    [_splashWindowController.window makeKeyAndOrderFront:nil];

    // Populate the database asynchronously.
    NSOperation *op = [[NSInvocationOperation alloc] initWithTarget:self
                                                            selector:@selector(_populateDatabase)
                                                              object:nil];
    [_operationQueue addOperation:op];
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

- (void)_populateDatabase
{
#if MEASURE_PARSE_SPEED
    [self _timeParseStart];
#endif //MEASURE_PARSE_SPEED


    QLog(@"%@", @"Calling loadTokens...");
    [self.appDatabase populate];
    QLog(@"%@", @"...Finished loadTokens.");



#if MEASURE_PARSE_SPEED
    [self _timeParseEnd];
#endif //MEASURE_PARSE_SPEED

    // Tell the main thread we're done populating the database, so it can proceed with the
    // rest of the app initialization.
    [self performSelectorOnMainThread:@selector(_didPopulateDatabase)
                           withObject:nil
                        waitUntilDone:NO];
}

// Called on the main thread when we're done populating the database.  Finishes
// initializing the app.
- (void)_didPopulateDatabase
{
    // Take down the splash window.
    [_splashWindowController.window close];
    _splashWindowController = nil;

    // Finish initializing the UI.
    [self _initGoMenu];
    [self _getFavoritesFromPrefs];

    // Register interest in window-close events.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_handleWindowWillCloseNotification:)
                                                 name:NSWindowWillCloseNotification
                                               object:nil];

    // Put the find panel controller in the responder chain.
    [[AKFindPanelController sharedInstance] setNextResponder:NSApp.nextResponder];
    NSApp.nextResponder = [AKFindPanelController sharedInstance];

    // Force the DIGSFindBuffer to initialize.
    //TODO: ??? Why not in DIGSFindBuffer's +initialize?
    (void)[DIGSFindBuffer sharedInstance];

    // Reopen windows from the previous session.
    [self _openInitialWindows];

    // Add the Debug menu if certain conditions are met.
    AKDebugging *debugging = [AKDebugging sharedInstance];

    debugging.nextResponder = NSApp.nextResponder;
    NSApp.nextResponder = debugging;

    if ([AKDebugging userCanDebug])
    {
        [debugging addDebugMenu];
    }

    // Set the provider of system services.
    NSApp.servicesProvider = [[AKServicesProvider alloc] init];
    NSUpdateDynamicServices();
    
    _finishedInitializing = YES;
}

- (void)_initGoMenu
{
    DIGSLogDebug_EnteringMethod();

    NSMenu *goMenu = _firstGoMenuDivider.menu;
    NSInteger menuIndex = [goMenu indexOfItem:_firstGoMenuDivider];

    for (NSString *fwName in [_appDatabase sortedFrameworkNames])
    {
        // See what information we have for this framework.
        NSArray *formalProtocolItems = [_appDatabase formalProtocolsForFrameworkNamed:fwName];
        NSArray *informalProtocolItems = [_appDatabase informalProtocolsForFrameworkNamed:fwName];
        NSArray *functionsGroupItems = [_appDatabase functionsGroupsForFrameworkNamed:fwName];
        NSArray *globalsGroupItems = [_appDatabase globalsGroupsForFrameworkNamed:fwName];

        // Construct the submenu of framework-related topics.
        NSMenu *fwTopicSubmenu = [[NSMenu alloc] initWithTitle:fwName];

        if (formalProtocolItems.count > 0)
        {
            NSMenuItem *subitem = [[NSMenuItem alloc] initWithTitle:AKProtocolsTopicName
                                                              action:@selector(selectFormalProtocolsTopic:)
                                                       keyEquivalent:@""];

            [fwTopicSubmenu addItem:subitem];
        }

        if (informalProtocolItems.count > 0)
        {
            NSMenuItem *subitem = [[NSMenuItem alloc] initWithTitle:AKInformalProtocolsTopicName
                                                              action:@selector(selectInformalProtocolsTopic:)
                                                       keyEquivalent:@""];

            [fwTopicSubmenu addItem:subitem];
        }

        if (functionsGroupItems.count > 0)
        {
            NSMenuItem *subitem = [[NSMenuItem alloc] initWithTitle:AKFunctionsTopicName
                                                              action:@selector(selectFunctionsTopic:)
                                                       keyEquivalent:@""];

            [fwTopicSubmenu addItem:subitem];
        }

        if (globalsGroupItems.count > 0)
        {
            NSMenuItem *subitem = [[NSMenuItem alloc] initWithTitle:AKGlobalsTopicName
                                                              action:@selector(selectGlobalsTopic:)
                                                       keyEquivalent:@""];

            [fwTopicSubmenu addItem:subitem];
        }

        // Construct the menu item to add to the Go menu, and add it.
        NSMenuItem *fwMenuItem = [[NSMenuItem alloc] initWithTitle:fwName
                                                             action:nil
                                                      keyEquivalent:@""];

        fwMenuItem.submenu = fwTopicSubmenu;
        menuIndex++;
        [goMenu insertItem:fwMenuItem atIndex:menuIndex];
    }
}

- (void)_openInitialWindows
{
    // If there's no saved window state, open a single new window.
    NSArray *savedWindows = [AKPrefUtils arrayValueForPref:AKSavedWindowStatesPrefName];

    if (savedWindows.count == 0)
    {
        (void)[self controllerForNewWindow];
        return;
    }

    // Restore windows from saved window state.
    NSInteger numWindows = savedWindows.count;
    NSInteger i;

    for (i = numWindows - 1; i >= 0; i--)
    {
        NSDictionary *prefDict = savedWindows[i];
        AKSavedWindowState *savedWindowState = [AKSavedWindowState fromPrefDictionary:prefDict];
        AKWindowLayout *windowLayout = savedWindowState.savedWindowLayout;
        AKWindowController *wc = [self _windowControllerForNewWindowWithLayout:windowLayout];

        [wc selectDocWithDocLocator:savedWindowState.savedDocLocator];
        [wc showWindow:nil];

        if (savedWindowState.savedWindowLayout.quicklistDrawerIsOpen)
        {
            [wc openQuicklistDrawer];
        }
    }
}

#pragma mark -
#pragma mark Private methods -- window management

- (NSWindow *)_frontmostBrowserWindow
{
    NSArray<NSNumber *> *windowNumbers = [NSWindow windowNumbersWithOptions:NSWindowNumberListAllSpaces];

    for (NSNumber *windowNum in windowNumbers)
    {
        NSWindow *win = [NSApp windowWithWindowNumber:windowNum.integerValue];
        id windowDelegate = win.delegate;

        if ([windowDelegate isKindOfClass:[AKWindowController class]])
        {
            return win;
        }
    }

    // If we got this far, there is no browser window open.
    return nil;
}

- (AKWindowController *)_windowControllerForNewWindowWithLayout:(AKWindowLayout *)windowLayout
{
    AKWindowController *wc = [[AKWindowController alloc] initWithDatabase:_appDatabase];

    [_windowControllers addObject:wc];
    if (windowLayout)
    {
        [wc takeWindowLayoutFrom:windowLayout];
    }

    return wc;
}

- (void)_handleWindowWillCloseNotification:(NSNotification *)notification
{
    id windowDelegate = ((NSWindow *)notification.object).delegate;

    if ([windowDelegate isKindOfClass:[AKWindowController class]])
    {
        // I've been getting some crashes after 0.998 that look like messages
        // are getting sent to a dealloc'ed object. I *suspect* it's because I
        // was over-releasing the window controller (see windowWillClose: in
        // AKWindowController). Between commenting that method out and adding
        // a retain/autorelease here, I think I fixed that.
        //
        // As evidence, I was able to get a crash consistently while running in
        // Instruments and closing a window.  Now, no longer.
        //
        // [2014-10-26] More info: I reproduced the crash by commenting this line
        // out (the retain/autorelease) and closing a window with the Search
        // quicklist selected and a non-zero number of search results.  Maybe I
        // have a memory bug in the Search stuff.  Anyway, it'll be moot when I
        // go to ARC.
        [_windowControllers removeObjectIdenticalTo:windowDelegate];
    }
}

// Takes snapshot of all open windows.  Returns array of dictionaries
// suitable for NSUserDefaults.
- (NSArray *)_allWindowsAsPrefArray
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray<NSNumber *> *windowNumbers = [NSWindow windowNumbersWithOptions:NSWindowNumberListAllSpaces];

    for (NSNumber *windowNum in windowNumbers)
    {
        NSWindow *win = [NSApp windowWithWindowNumber:windowNum.integerValue];
        id windowDelegate = win.delegate;

        if ([windowDelegate isKindOfClass:[AKWindowController class]])
        {
            AKWindowController *wc = (AKWindowController *)windowDelegate;
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
        || (latestAppVersionString.length > 30))
    {
        DIGSLogWarning(@"the received contents of the version-number URL don't"
                       @" look like a valid version string");
        return nil;
    }
    
    latestAppVersionString = [latestAppVersionString substringFromIndex:expectedPrefix.length];
    
    return [AKAppVersion appVersionFromString:latestAppVersionString];
}

#pragma mark -
#pragma mark Private methods -- Favorites

- (void)_getFavoritesFromPrefs
{
    DIGSLogDebug_EnteringMethod();
    
    NSArray *favPrefList = [AKPrefUtils arrayValueForPref:AKFavoritesPrefName];
    NSInteger numFavs = favPrefList.count;
    NSInteger i;

    // Get values from NSUserDefaults.
    [_favoritesList removeAllObjects];
    BOOL someFavsWereInvalid = NO;
    for (i = 0; i < numFavs; i++)
    {
        id favPref = favPrefList[i];
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
    NSInteger numFavs = _favoritesList.count;
    NSInteger i;

    // Update the UserDefaults.
    for (i = 0; i < numFavs; i++)
    {
        AKDocLocator *favItem = _favoritesList[i];

        [favPrefList addObject:[favItem asPrefDictionary]];
    }
    [AKPrefUtils setArrayValue:favPrefList forPref:AKFavoritesPrefName];

    // Update the Favorites menu.
    [self _updateFavoritesMenu];
}

- (void)_updateFavoritesMenu
{
    NSMenu *mainMenu = NSApp.mainMenu;
    NSMenu *favoritesMenu = [mainMenu itemWithTitle:@"Favorites"].submenu;
    NSInteger numFavs = _favoritesList.count;
    NSInteger i;

    while (favoritesMenu.numberOfItems > 2)
    {
        [favoritesMenu removeItemAtIndex:2];
    }

    for (i = 0; i < numFavs; i++)
    {
        AKDocLocator *favItem = _favoritesList[i];
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[favItem stringToDisplayInLists]
                                                           action:@selector(selectDocWithDocLocatorRepresentedBy:)
                                                    keyEquivalent:@""];

        if (i < 9)
        {
            menuItem.keyEquivalent = [NSString stringWithFormat:@"%ld", (long)(i + 1)];
            menuItem.keyEquivalentModifierMask = NSControlKeyMask;
        }

        menuItem.representedObject = favItem;
        [favoritesMenu addItem:menuItem];
    }
}

@end
