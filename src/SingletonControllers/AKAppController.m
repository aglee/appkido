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
#import "AKDatabase.h"
#import "AKDatabaseXMLExporter.h"
#import "AKDebugUtils.h"
#import "AKDevTools.h"
#import "AKDevToolsPanelController.h"
#import "AKDevToolsPathController.h"
#import "AKDevToolsUtils.h"
#import "AKDocLocator.h"
#import "AKDocSetIndex.h"
#import "AKFileUtils.h"
#import "AKFrameworkConstants.h"
#import "AKIPhoneDevTools.h"
#import "AKPrefUtils.h"
#import "AKPrefPanelController.h"
#import "AKQuicklistController.h"
#import "AKSavedWindowState.h"
#import "AKServicesProvider.h"
#import "AKTextUtils.h"
#import "AKTopic.h"
#import "AKViewUtils.h"
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
    return [[AKAppController sharedInstance] handleSearchScriptCommand:aCommand];
}

@end


#pragma mark -
#pragma mark Forward declarations of private methods

@interface AKAppController (Private)

// Private methods -- steps during launch
- (void)_initGoMenu;
- (void)_maybeAddDebugMenu;  // [agl] uses AKDebugUtils

// Private methods -- window management
- (NSWindow *)_frontmostBrowserWindow;
- (AKWindowController *)_windowControllerForNewWindowWithLayout:(AKWindowLayout *)windowLayout;
- (void)_handleWindowWillCloseNotification:(NSNotification *)notification;
- (void)_openInitialWindows;
- (NSArray *)_allWindowsAsPrefArray;

// Private methods -- version management
- (AKAppVersion *)_latestAppVersion;

// Private methods -- Favorites
- (void)_getFavoritesFromPrefs;
- (void)_putFavoritesIntoPrefs;
- (void)_updateFavoritesMenu;

@end


#pragma mark -

@implementation AKAppController

#pragma mark -
#pragma mark Factory methods

static id s_sharedInstance = nil;  // Value will be set by -init.

+ (id)sharedInstance
{
    return s_sharedInstance;
}


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
        _finishedInitializing = NO;
        _windowControllers = [[NSMutableArray alloc] init];
        _favoritesList = [[NSMutableArray alloc] init];

        // It's okay to assume this class will be instantiated exactly once.
        s_sharedInstance = self;
    }

    return self;
}

- (void)awakeFromNib
{
    DIGSLogDebug_EnteringMethod();

	// Create an AKDatabase instance, or give the user the option to quit.
    NSMutableArray *errorStrings = [NSMutableArray array];
	while (_appDatabase == nil)
	{
		// If necessary, prompt the user for a valid Dev Tools path and SDK version.
		while (![AKDevTools looksLikeValidDevToolsPath:[AKPrefUtils devToolsPathPref]
                                          errorStrings:errorStrings])
		{
            if ([AKPrefUtils devToolsPathPref])
            {
                NSString *errorMessage = [NSString stringWithFormat:@"%@ doesn't seem to be a Dev Tools directory.\n\n%@",
                                          [AKPrefUtils devToolsPathPref],
                                          [errorStrings componentsJoinedByString:@"\n"]];
                NSAlert *alert = [NSAlert alertWithMessageText:errorMessage
                                                 defaultButton:@"OK"
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@""];
                [alert runModal];
                [errorStrings removeAllObjects];
            }
            
			if (![[AKDevToolsPanelController controller] runDevToolsSetupPanel])
			{
				// The user cancelled, so quit the application.
				[[NSApplication sharedApplication] terminate:self];
			}
		}
		DIGSLogDebug(@"dev tools path is [%@]", [AKPrefUtils devToolsPathPref]);

		// Try to create a database instance based on the user's selected Dev Tools path and SDK version.
#if APPKIDO_FOR_IPHONE
		_appDatabase = [[AKDatabase databaseForIPhonePlatform] retain];
#else
		_appDatabase = [[AKDatabase databaseForMacPlatform] retain];
#endif
		if (_appDatabase == nil)
		{
			[AKPrefUtils setDevToolsPathPref:nil];
			[AKPrefUtils setSDKVersionPref:nil];
		}
	}

    // Put up the splash window.
    [_splashVersionField setStringValue:[[AKAppVersion appVersion] displayString]];
    [_splashWindow setReleasedWhenClosed:YES];
    [_splashWindow center];
    [_splashWindow makeKeyAndOrderFront:nil];

    // Populate the database(s) by parsing files for each of the selected frameworks in the user's prefs.
    [_splashMessageField setStringValue:@"Parsing files for framework:"];
    [_splashMessageField display];

// [agl] working on performance
#if MEASURE_PARSE_SPEED
[self _timeParseStart];
#endif //MEASURE_PARSE_SPEED

    [_appDatabase setDelegate:self];  // So we can update the splash screen.
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AKFoundationOnly"])
        {
            // Special debug mode so launch is quicker.
            // defaults write com.digitalspokes.appkido AKFoundationOnly YES  # or NO
            // defaults write com.appkido.appkidoforiphone AKFoundationOnly YES  # or NO
            [_appDatabase loadTokensForFrameworks:[NSArray arrayWithObject:@"Foundation"]];
        }
        else
        {
            [_appDatabase loadTokensForFrameworks:[AKPrefUtils selectedFrameworkNamesPref]];
        }
    }
    [_appDatabase setDelegate:nil];  // Avoid dangling weak references.

// [agl] working on performance
#if MEASURE_PARSE_SPEED
[self _timeParseEnd];
#endif //MEASURE_PARSE_SPEED

    [_splashMessage2Field setStringValue:@""];
    [_splashMessage2Field display];

    // Set up the "Go" menu.
    [self _initGoMenu];

    // Update the UI with the Favorites list from the user preferences.
    [self _getFavoritesFromPrefs];

    // Take down the splash window.
    [_splashWindow close];
    _splashWindow = nil;
    _splashVersionField = nil;
    _splashMessageField = nil;
    _splashMessage2Field = nil;

    // Register interest in window-close events.
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(_handleWindowWillCloseNotification:)
        name:NSWindowWillCloseNotification
        object:nil];

    // Force the DIGSFindBuffer to initialize.
    // [agl] ??? Why not in DIGSFindBuffer's +initialize?
    (void)[DIGSFindBuffer sharedInstance];

    DIGSLogDebug_ExitingMethod();
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_appDatabase release];

    [_aboutWindowController release];
    [_windowControllers release];
    [_prefPanelController release];
    [_favoritesList release];

    [super dealloc];
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

    [fav retain];
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
    [fav release];
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
    
    [_aboutWindowController showWindow:nil];
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

    NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingAtPath:[savePanel filename]];

    if (fh == nil)
    {
        DIGSLogError_ExitingMethodPrematurely(
            ([NSString stringWithFormat:@"failed to get file handle for [%@]", [savePanel filename]]));
        return;
    }

    AKDatabaseXMLExporter *exporter =
        [[[AKDatabaseXMLExporter alloc] initWithDatabase:_appDatabase fileHandle:fh] autorelease];
    [exporter doExport];
    [fh closeFile];
}

// [agl] uses AKDebugUtils
- (IBAction)_testParser:(id)sender
{
    [AKFileSectionDebug _testParser];
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
    else if ((itemAction == @selector(_testParser:)) // [agl] uses AKDebugUtils
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
    DIGSLogDebug_EnteringMethod();
    
    // Reopen windows from the previous session.
    [self _openInitialWindows];

    // Add the Debug menu if certain conditions are met.
    [self _maybeAddDebugMenu];  // [agl] uses AKDebugUtils
    
    // Set the provider of system services.
    [NSApp setServicesProvider:[[[AKServicesProvider alloc] init] autorelease]];
    NSUpdateDynamicServices();

    _finishedInitializing = YES;
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
#pragma mark AKDatabase delegate methods

- (void)database:(AKDatabase *)database willLoadTokensForFramework:(NSString *)frameworkName
{
    [_splashMessage2Field setStringValue:frameworkName];
    [_splashMessage2Field display];
}


#pragma mark -
#pragma mark Private methods -- steps during launch

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
        NSMenu *fwTopicSubmenu = [[[NSMenu alloc] initWithTitle:fwName] autorelease];

        if ([formalProtocolNodes count] > 0)
        {
            NSMenuItem *subitem =
                [[[NSMenuItem alloc]
                    initWithTitle:AKProtocolsTopicName
                    action:@selector(jumpToFrameworkFormalProtocols:)
                    keyEquivalent:@""]
                    autorelease];

            [fwTopicSubmenu addItem:subitem];
        }

        if ([informalProtocolNodes count] > 0)
        {
            NSMenuItem *subitem =
                [[[NSMenuItem alloc]
                    initWithTitle:AKInformalProtocolsTopicName
                    action:@selector(jumpToFrameworkInformalProtocols:)
                    keyEquivalent:@""]
                    autorelease];

            [fwTopicSubmenu addItem:subitem];
        }

        if ([functionsGroupNodes count] > 0)
        {
            NSMenuItem *subitem =
                [[[NSMenuItem alloc]
                    initWithTitle:AKFunctionsTopicName
                    action:@selector(jumpToFrameworkFunctions:)
                    keyEquivalent:@""]
                    autorelease];

            [fwTopicSubmenu addItem:subitem];
        }

        if ([globalsGroupNodes count] > 0)
        {
            NSMenuItem *subitem =
                [[[NSMenuItem alloc]
                    initWithTitle:AKGlobalsTopicName
                    action:@selector(jumpToFrameworkGlobals:)
                    keyEquivalent:@""]
                    autorelease];

            [fwTopicSubmenu addItem:subitem];
        }

        // Construct the menu item to add to the Go menu, and add it.
        NSMenuItem *fwMenuItem =
            [[[NSMenuItem alloc]
                initWithTitle:fwName
                action:nil
                keyEquivalent:@""]
                autorelease];

        [fwMenuItem setSubmenu:fwTopicSubmenu];
        menuIndex++;
        [goMenu insertItem:fwMenuItem atIndex:menuIndex];
    }
}

// [agl] uses AKDebugUtils
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
        NSMenu *debugSubmenu = [[[NSMenu alloc] initWithTitle:@"Debug"] autorelease];

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
    AKWindowController *windowController = [[[AKWindowController alloc] initWithDatabase:_appDatabase] autorelease];

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
            AKSavedWindowState *savedWindowState = [[[AKSavedWindowState alloc] init] autorelease];

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
            [[[NSMenuItem alloc]
                initWithTitle:[favItem stringToDisplayInLists]
                action:@selector(jumpToDocLocatorRepresentedBy:)
                keyEquivalent:@""] autorelease];

        if (i < 9)
        {
            [menuItem setKeyEquivalent:[NSString stringWithFormat:@"%d", (i + 1)]];
            [menuItem setKeyEquivalentModifierMask:NSControlKeyMask];
        }

        [menuItem setRepresentedObject:favItem];
        [favoritesMenu addItem:menuItem];
    }
}

@end
