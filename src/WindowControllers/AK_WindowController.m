/*
 * AK_WindowController.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AK_WindowController.h"

#import "DIGSLog.h"

#import "AKAppController.h"
#import "AKClassNode.h"
#import "AKClassTopic.h"
#import "AKDatabase.h"
#import "AKDoc.h"
#import "AK_DocListViewController.h"
#import "AKDocLocator.h"
#import "AKDocView.h"
#import "AK_DocViewController.h"
#import "AKFileSection.h"
#import "AKFindPanelController.h"
#import "AKFormalProtocolsTopic.h"
#import "AKFunctionsTopic.h"
#import "AKGlobalsTopic.h"
#import "AKInformalProtocolsTopic.h"
#import "AKLinkResolver.h"
#import "AKOldLinkResolver.h"
#import "AKPrefUtils.h"
#import "AKProtocolTopic.h"
#import "AK_QuicklistViewController.h"
#import "AKSavedWindowState.h"
#import "AK_SubtopicListViewController.h"
#import "AK_TopicBrowserViewController.h"
#import "AKViewUtils.h"
#import "AKWindowLayout.h"

@implementation AK_WindowController

@synthesize topLevelSplitView = _topLevelSplitView;
@synthesize topicBrowserView = _topicBrowserView;

@synthesize innerSplitView = _innerSplitView;

@synthesize middleView = _middleView;
@synthesize subtopicListView = _subtopicListView;
@synthesize docListView = _docListView;
@synthesize docView = _docView;

@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize superclassButton = _superclassButton;

@synthesize backMenu = _backMenu;
@synthesize forwardMenu = _forwardMenu;
@synthesize superclassesMenu = _superclassesMenu;

@synthesize topicDescriptionField = _topicDescriptionField;
@synthesize quicklistDrawer = _quicklistDrawer;

#pragma mark -
#pragma mark Private constants -- toolbar identifiers

static NSString *_AKToolbarID = @"AKToolbarID";

#pragma mark -
#pragma mark Init/dealloc/awake

- (id)initWithDatabase:(AKDatabase *)database
{
    if ((self = [super initWithWindowNibName:@"AKWindow"]))
    {
        _database = [database retain];

        NSInteger maxHistory = [AKPrefUtils intValueForPref:AKMaxHistoryPrefName];

        _windowHistory = [[NSMutableArray alloc] initWithCapacity:maxHistory];
        _windowHistoryIndex = -1;
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}

- (void)dealloc
{
    [_database release];
    
    [_windowHistory release];

    [_topicBrowserController release];
    [_subtopicListController release];
    [_docListController release];
    [_docViewController release];
    [_quicklistController release];

    [_quicklistDrawer release];

    [super dealloc];
}

#pragma mark -
#pragma mark Getters and setters

- (AKDatabase *)database
{
    return _database;
}

- (AKDocLocator *)currentHistoryItem
{
    return (_windowHistoryIndex < 0) ? nil : [_windowHistory objectAtIndex:_windowHistoryIndex];
}

- (AKDoc *)currentDoc
{
    AKDocLocator *docLocator = [self currentHistoryItem];
    AKDoc *currentDoc = [docLocator docToDisplay];
    
    if (currentDoc == nil)    //  try General/Overview instead
    {
        docLocator = [AKDocLocator withTopic:[docLocator topicToDisplay]
                                subtopicName:@"General"
                                     docName: @"Overview"];
        currentDoc = [docLocator docToDisplay];
    }
    
    return currentDoc;
}

- (NSString *)currentDocPath
{
    AKDocLocator *docLocator = [self currentHistoryItem];
    AKDoc *currentDoc = [docLocator docToDisplay];
    
    if (currentDoc == nil)
    {
        docLocator = [AKDocLocator withTopic:[docLocator topicToDisplay]
                                subtopicName:@"General"
                                     docName: @"Overview"];
        currentDoc = [docLocator docToDisplay];
    }
    
    return [[currentDoc fileSection] filePath];
}

- (NSURL *)currentDocURL
{
    NSString *docPath = [self currentDocPath];
    
    if (docPath == nil)
    {
        return nil;
    }
    
    return [[[NSURL fileURLWithPath:docPath] absoluteURL] standardizedURL];
}

#pragma mark -
#pragma mark Navigation

- (void)openWindowWithQuicklistDrawer:(BOOL)drawerIsOpen
{
    // Display the window and set the drawer state, in that order.  Can't
    // set drawer state on an undisplayed window.
    [[self window] makeKeyAndOrderFront:nil];

    if (drawerIsOpen)
    {
        [_quicklistDrawer openOnEdge:NSMinXEdge];
    }

    // KLUDGE: The shadow seems to get screwed up by the drawer stuff, so force it
    // to get redrawn.  Note that -invalidateShadow does not exist in
    // 10.1, so use -setHasShadow: instead.
    [[self window] setHasShadow:NO];
    [[self window] setHasShadow:YES];
}

- (void)jumpToTopic:(AKTopic *)obj
{
    AKDocLocator *currentItem = [self currentHistoryItem];

    [self jumpToTopic:obj subtopicName:[currentItem subtopicName] docName:[currentItem docName]];
}

- (void)jumpToSubtopicWithName:(NSString *)subtopicName
{
    AKDocLocator *currentItem = [self currentHistoryItem];

    [self jumpToTopic:[currentItem topicToDisplay] subtopicName:subtopicName docName:[currentItem docName]];
}

- (void)jumpToDocName:(NSString *)docName
{
    AKDocLocator *currentItem = [self currentHistoryItem];

    [self jumpToTopic:[currentItem topicToDisplay] subtopicName:[currentItem subtopicName] docName:docName];
}

- (void)jumpToDocLocator:(AKDocLocator *)docLocator
{
    [self jumpToTopic:[docLocator topicToDisplay] subtopicName:[docLocator subtopicName] docName:[docLocator docName]];
}

// all the other "jumpTo" methods must come through here
- (void)jumpToTopic:(AKTopic *)topic subtopicName:(NSString *)subtopicName docName:(NSString *)docName
{
    if (topic == nil)
    {
        DIGSLogInfo(@"can't navigate to a nil topic");
        return;
    }

    [self _rememberCurrentTextSelection];

    AKDocLocator *newHistoryItem = [AKDocLocator withTopic:topic subtopicName:subtopicName docName:docName];

    [_topicBrowserController navigateFrom:[self currentHistoryItem] to:newHistoryItem];
    [self _addHistoryItem:newHistoryItem];
}

- (BOOL)jumpToLinkURL:(NSURL *)linkURL
{
    // Interpret the link URL as relative to the current doc URL.
    NSString *currentDocFilePath = [[[[self currentHistoryItem] docToDisplay] fileSection] filePath];
    NSURL *currentDocFileURL = [NSURL fileURLWithPath:currentDocFilePath];
    NSURL *destinationURL = [NSURL URLWithString:[linkURL relativeString] relativeToURL:currentDocFileURL];

    // If we have a file: URL, try to derive a doc locator from it.
    AKDocLocator *docLocator = nil;
    if (![destinationURL isFileURL])
    {
        AKLinkResolver *linkResolver = [AKLinkResolver linkResolverWithDatabase:_database];
        docLocator = [linkResolver docLocatorForURL:destinationURL];

        if (docLocator == nil)
        {
            DIGSLogDebug(@"resorting to AKOldLinkResolver for %@", linkURL);
            linkResolver = [AKOldLinkResolver linkResolverWithDatabase:_database];
            docLocator = [linkResolver docLocatorForURL:destinationURL];
        }
    }

    // If we managed to derive a doc locator, jump to it. Otherwise, try opening
    // the file in the user's browser.
    if (docLocator)
    {
        [self jumpToDocLocator:docLocator];
        [_docListController focusOnDocListTable];
        [[_topLevelSplitView window] makeKeyAndOrderFront:nil];
        return YES;
    }
    else if ([[NSWorkspace sharedWorkspace] openURL:destinationURL])
    {
        DIGSLogDebug(@"NSWorkspace opened URL [%@]", destinationURL);
        return YES;
    }
    else
    {
        DIGSLogWarning(@"NSWorkspace couldn't open URL [%@]", destinationURL);
        return NO;
    }
}

- (void)bringToFront
{
    [[self window] makeKeyAndOrderFront:nil];
}

- (void)searchForString:(NSString *)aString
{
    NSInteger state = [_quicklistDrawer state];
    if ((state == NSDrawerClosedState) || (state == NSDrawerClosingState))
    {
        [self toggleQuicklistDrawer:nil];
    }
    [_quicklistController searchForString:aString];
}

- (void)putSavedWindowStateInto:(AKSavedWindowState *)savedWindowState
{
    AKWindowLayout *windowLayout = [[[AKWindowLayout alloc] init] autorelease];

    [self putWindowLayoutInto:windowLayout];

    [savedWindowState setSavedWindowLayout:windowLayout];
    [savedWindowState setSavedDocLocator:[self currentHistoryItem]];
}

#pragma mark -
#pragma mark Action methods -- window layout

- (IBAction)rememberWindowLayout:(id)sender
{
    AKWindowLayout *windowLayout = [[[AKWindowLayout alloc] init] autorelease];
    [self putWindowLayoutInto:windowLayout];

    NSDictionary *prefDictionary = [windowLayout asPrefDictionary];
    [AKPrefUtils setDictionaryValue:prefDictionary forPref:AKLayoutForNewWindowsPrefName];
}

- (IBAction)addBrowserColumn:(id)sender
{
    [_topicBrowserController addBrowserColumn:nil];
}

- (IBAction)removeBrowserColumn:(id)sender
{
    [_topicBrowserController removeBrowserColumn:nil];
}

- (IBAction)jumpToSubtopicWithIndexFromTag:(id)sender
{
    [_topicBrowserController jumpToSubtopicWithIndex:[sender tag]];
}

- (IBAction)toggleBrowserVisible:(id)sender
{
    NSRect browserFrame = [_topicBrowserView frame];

    if (browserFrame.size.height == 0.0)
    {
        [_topLevelSplitView ak_setHeight:[self _computeBrowserHeight] ofSubview:_topicBrowserView];
    }
    else
    {
        [_topLevelSplitView ak_setHeight:0.0 ofSubview:_topicBrowserView];
    }

// [agl] KLUDGE -- for some reason the scroll view does not retile
// automatically, so I force it here; the reason I traverse all subviews
// is because the internal view hierarchy of WebView is not exposed
    NSMutableArray *allSubviews = [NSMutableArray arrayWithArray:[_docView subviews]];
    unsigned subviewIndex = 0;

    while (subviewIndex < [allSubviews count])
    {
        NSView *view = [allSubviews objectAtIndex:subviewIndex];

        [allSubviews addObjectsFromArray:[view subviews]];

        subviewIndex++;
    }

    for (subviewIndex = 0; subviewIndex < [allSubviews count]; subviewIndex++)
    {
        NSView *view = [allSubviews objectAtIndex:subviewIndex];

        if ([view isKindOfClass:[NSScrollView class]])
        {
            [(NSScrollView *)view tile];
        }
    }
}

- (IBAction)showBrowser:(id)sender
{
    if ([_topicBrowserView frame].size.height == 0.0)
    {
        [self toggleBrowserVisible:nil];
    }
}

- (IBAction)toggleQuicklistDrawer:(id)sender
{
    NSInteger state = [_quicklistDrawer state];

    if ((state == NSDrawerClosedState) || (state == NSDrawerClosingState))
    {
        [_quicklistDrawer openOnEdge:NSMinXEdge];
    }
    else
    {
        [_quicklistDrawer close];
    }
}

#pragma mark -
#pragma mark Action methods -- navigation

- (IBAction)navigateBack:(id)sender
{
    if (_windowHistoryIndex > 0)
    {
        [self _navigateToHistoryIndex:(_windowHistoryIndex - 1)];
    }
}

- (IBAction)navigateForward:(id)sender
{
    if (_windowHistoryIndex < ((int)[_windowHistory count] - 1))
    {
        [self _navigateToHistoryIndex:(_windowHistoryIndex + 1)];
    }
}

- (IBAction)doBackMenuAction:(id)sender
{
    // Figure out how far back in history to navigate.
    NSInteger offset = [_backMenu indexOfItem:(NSMenuItem *)sender] + 1;

    // Do the navigation.
    [self _navigateToHistoryIndex:(_windowHistoryIndex - offset)];
}

- (IBAction)doForwardMenuAction:(id)sender
{
    // Figure out how far forward in history to navigate.
    NSInteger offset = [_forwardMenu indexOfItem:(NSMenuItem *)sender] + 1;

    // Do the navigation.
    [self _navigateToHistoryIndex:(_windowHistoryIndex + offset)];
}

- (IBAction)jumpToSuperclass:(id)sender
{
    AKClassNode *superclassNode = [[self _currentTopic] parentClassOfTopic];

    if (superclassNode)
    {
        [self jumpToTopic:[AKClassTopic topicWithClassNode:superclassNode]];
    }
}

// We expect sender to be an NSMenuItem.
- (IBAction)jumpToAncestorClass:(id)sender
{
    AKClassNode * classNode = [[self _currentTopic] parentClassOfTopic];
    NSInteger numberOfSuperlevels;
    NSInteger i;

    if (classNode == nil)
    {
        return;
    }

    // Figure out how far back in our ancestry to jump.
    numberOfSuperlevels = [_superclassesMenu indexOfItem:sender];

    // Figure out what class that means to jump to.
    for (i = 0; i < numberOfSuperlevels; i++)
    {
        classNode = [classNode parentClass];
    }

    // Do the jump.
    [self jumpToTopic:[AKClassTopic topicWithClassNode:classNode]];
}

- (IBAction)jumpToFrameworkFormalProtocols:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]])
    {
        NSString *fwName = [[sender menu] title];

        [self jumpToTopic:[AKFormalProtocolsTopic topicWithFrameworkNamed:fwName inDatabase:_database]];

        [self showBrowser:nil];
    }
}

- (IBAction)jumpToFrameworkInformalProtocols:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]])
    {
        NSString *fwName = [[sender menu] title];

        [self jumpToTopic:[AKInformalProtocolsTopic topicWithFrameworkNamed:fwName inDatabase:_database]];
        [self showBrowser:nil];
    }
}

- (IBAction)jumpToFrameworkFunctions:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]])
    {
        NSString *fwName = [[sender menu] title];

        [self jumpToTopic:[AKFunctionsTopic topicWithFrameworkNamed:fwName inDatabase:_database]];
        [self showBrowser:nil];
    }
}

- (IBAction)jumpToFrameworkGlobals:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]])
    {
        NSString *fwName = [[sender menu] title];

        [self jumpToTopic:[AKGlobalsTopic topicWithFrameworkNamed:fwName inDatabase:_database]];
        [self showBrowser:nil];
    }
}

- (IBAction)jumpToDocLocatorRepresentedBy:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]])
    {
        [self jumpToDocLocator:[sender representedObject]];
    }
}

- (IBAction)addTopicToFavorites:(id)sender
{
    [(AKAppController *)[NSApp delegate]
        addFavorite:[AKDocLocator withTopic:[self _currentTopic] subtopicName:nil docName:nil]];
}

- (IBAction)findNext:(id)sender
{
    [[AKFindPanelController sharedInstance] findNext:nil];
}

- (IBAction)findPrevious:(id)sender
{
    [[AKFindPanelController sharedInstance] findPrevious:nil];
}

- (IBAction)revealDocFileInFinder:(id)sender
{
    NSString *docPath = [self currentDocPath];
    
    if (docPath == nil)
    {
        return;
    }

    NSString *containingDirPath = [docPath stringByDeletingLastPathComponent];
    [[NSWorkspace sharedWorkspace] selectFile:docPath
                     inFileViewerRootedAtPath:containingDirPath];
    
//    // Construct and execute an AppleScript command that asks the Finder
//    // to reveal the file.
//    NSString *appleScriptCommand =
//        [NSString
//            stringWithFormat:
//                @"tell application \"Finder\"\n"
//                @"    reveal posix file \"%@\"\n"
//                @"    activate\n"
//                @"end tell",
//                docPath];
//    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:appleScriptCommand];
//    NSDictionary *errorInfo = nil;
//    NSAppleEventDescriptor *appleEventDescriptor = [appleScript executeAndReturnError:&errorInfo];
//
//    if (appleEventDescriptor == nil)
//    {
//        DIGSLogError(@"Error executing AppleScript: %@", errorInfo);
//    }
}

- (IBAction)copyDocTextURL:(id)sender
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];

    [pasteboard declareTypes:@[NSStringPboardType] owner:nil];
    [pasteboard setString:[[self currentDocURL] absoluteString] forType:NSStringPboardType];
}

- (IBAction)openDocURLInBrowser:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[self currentDocURL]];
}

- (IBAction)selectPreviousSearchResult:(id)sender
{
    NSInteger state = [_quicklistDrawer state];

    if ((state == NSDrawerClosedState) || (state == NSDrawerClosingState))
    {
        [self toggleQuicklistDrawer:nil];
    }

    [_quicklistController selectPreviousSearchResult:sender];
}

- (IBAction)selectNextSearchResult:(id)sender
{
    NSInteger state = [_quicklistDrawer state];

    if ((state == NSDrawerClosedState) || (state == NSDrawerClosingState))
    {
        [self toggleQuicklistDrawer:nil];
    }

    [_quicklistController selectNextSearchResult:sender];
}

#pragma mark -
#pragma mark AK_UIController methods

- (void)applyUserPreferences
{
    [_topicBrowserController applyUserPreferences];
    [_quicklistController applyUserPreferences];
}

- (BOOL)validateItem:(id)anItem
{
    SEL itemAction = [anItem action];

    if ((itemAction == @selector(copyDocTextURL:))
        || (itemAction == @selector(openDocURLInBrowser:))
        || (itemAction == @selector(revealDocFileInFinder:)))
    {
        return ([self currentDoc] != nil);
    }
    else if (itemAction == @selector(navigateBack:))
    {
        return (_windowHistoryIndex > 0);
    }
    else if (itemAction == @selector(navigateForward:))
    {
        return (_windowHistoryIndex < ((int)[_windowHistory count] - 1));
    }
    else if ((itemAction == @selector(doBackMenuAction:))
             || (itemAction == @selector(doForwardMenuAction:)))
    {
        return YES;
    }
    else if ((itemAction == @selector(jumpToSuperclass:))
             || (itemAction == @selector(jumpToAncestorClass:)))
    {
        return ([[self _currentTopic] parentClassOfTopic] != nil);
    }
    else if (itemAction == @selector(jumpToSubtopicWithIndexFromTag:))
    {
        return YES;
    }
    else if ((itemAction == @selector(jumpToFrameworkFormalProtocols:))
             || (itemAction == @selector(jumpToFrameworkInformalProtocols:))
             || (itemAction == @selector(jumpToFrameworkFunctions:))
             || (itemAction == @selector(jumpToFrameworkGlobals:))
             || (itemAction == @selector(jumpToDocLocatorRepresentedBy:))
             || (itemAction == @selector(rememberWindowLayout:)))
    {
        return YES;
    }
    else if (itemAction == @selector(addTopicToFavorites:))
    {
        AKTopic *currentTopic = [self _currentTopic];

        // Update the menu item title to reflect what's currently selected in the topic browser.
        if ([anItem isKindOfClass:[NSMenuItem class]])
        {
            NSString *topicName = [currentTopic stringToDisplayInTopicBrowser];
            NSString *menuTitle = [NSString stringWithFormat:@"Add \"%@\" to Favorites", topicName];

            [anItem setTitle:menuTitle];
        }

        // Enable the item if the selected topic isn't already a favorite.
        AKAppController *appController = [NSApp delegate];
        NSArray *favoritesList = [appController favoritesList];
        AKDocLocator *proposedFavorite = [AKDocLocator withTopic:currentTopic subtopicName:nil docName:nil];

        if ([favoritesList containsObject:proposedFavorite])
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else if (itemAction == @selector(toggleQuicklistDrawer:))
    {
        if ([anItem isKindOfClass:[NSMenuItem class]])
        {
            NSInteger state = [_quicklistDrawer state];

            if ((state == NSDrawerClosedState)
                || (state == NSDrawerClosingState))
            {
                [anItem setTitle:@"Show Quicklist"];
            }
            else
            {
                [anItem setTitle:@"Hide Quicklist"];
            }
        }

        return YES;
    }
    else if (itemAction == @selector(toggleBrowserVisible:))
    {
        if ([anItem isKindOfClass:[NSMenuItem class]])  // [agl] what if it's a toolbar item?
        {
            if (([_topicBrowserView frame].size.height == 0.0)
                && (_browserFractionWhenVisible > 0.0))
            {
                [anItem setTitle:@"Show Browser"];
            }
            else
            {
                [anItem setTitle:@"Hide Browser"];
            }
        }

        return YES;
    }
    else if ([_topicBrowserController validateItem:anItem])
    {
        return YES;
    }
    else
    {
        return [_quicklistController validateItem:anItem];
    }
}

- (void)takeWindowLayoutFrom:(AKWindowLayout *)windowLayout
{
    if (windowLayout == nil)
    {
        return;
    }

    // Apply the specified window frame.
    [[self window] setFrame:[windowLayout windowFrame] display:NO];

    // Restore the visibility of the toolbar.
    [[[self window] toolbar] setVisible:[windowLayout toolbarIsVisible]];

    // Apply the new browser fraction.  Note that -_computerBrowserHeight
    // uses the _browserFractionWhenVisible ivar, so we make sure to set
    // the ivar first.
    _browserFractionWhenVisible = [windowLayout browserFraction];
    if (([_topicBrowserView frame].size.height > 0.0) && [windowLayout browserIsVisible])
    {
        [_topLevelSplitView ak_setHeight:[self _computeBrowserHeight] ofSubview:_topicBrowserView];
    }
    else
    {
        [_topLevelSplitView ak_setHeight:0.0 ofSubview:_topicBrowserView];
    }

    // Restore the state of the inner split view.
    [_innerSplitView ak_setHeight:[windowLayout middleViewHeight] ofSubview:_middleView];
    
    [_subtopicListController takeWindowLayoutFrom:windowLayout];
    [_docListController takeWindowLayoutFrom:windowLayout];
    [_docViewController takeWindowLayoutFrom:windowLayout];

    // Restore the state of the Quicklist drawer.
    NSSize drawerContentSize = [_quicklistDrawer contentSize];

    drawerContentSize.width = [windowLayout quicklistDrawerWidth];
    [_quicklistDrawer setContentSize:drawerContentSize];

    // Restore the internal state of the Quicklist.
    [_quicklistController takeWindowLayoutFrom:windowLayout];
}

- (void)putWindowLayoutInto:(AKWindowLayout *)windowLayout
{
    if (windowLayout == nil)
    {
        return;
    }

    // Remember the current window frame.
    [windowLayout setWindowFrame:[[self window] frame]];

    // Remember the visibility of the toolbar.
    [windowLayout setToolbarIsVisible:[[[self window] toolbar] isVisible]];

    // Remember the state of the inner split view.
    [windowLayout setMiddleViewHeight:([_middleView frame].size.height)];

    // Remember the state of the browser.
    [windowLayout setBrowserIsVisible:([_topicBrowserView frame].size.height > 0)];
    [windowLayout setBrowserFraction:_browserFractionWhenVisible];
    [_topicBrowserController putWindowLayoutInto:windowLayout];

    // Remember the state of the Quicklist drawer.
    NSInteger state = [_quicklistDrawer state];
    BOOL drawerIsOpen = (state == NSDrawerOpenState) || (state == NSDrawerOpeningState);

    [windowLayout setQuicklistDrawerIsOpen:drawerIsOpen];
    [windowLayout setQuicklistDrawerWidth:([_quicklistDrawer contentSize].width)];

    // Remember the internal state of the Quicklist.
    [_quicklistController putWindowLayoutInto:windowLayout];
}

#pragma mark -
#pragma mark NSWindowController methods

- (void)windowDidLoad
{
    // Set up the toolbar.
    [self _initToolbar];

    // Get the initial value for the height of the browser.
    _browserFractionWhenVisible = [self _computeBrowserFraction];

    // Initialize my view controllers.
    [self _setUpViewControllers];

    // Apply display preferences *after* all awake-from-nibs have been
    // done, because DIGSMarginViews have to have fully initialized
    // themselves before we go resizing things or swapping subviews around.
    [self applyUserPreferences];

    // Select NSObject.
    _windowHistoryIndex = -1;
    [_windowHistory removeAllObjects];

    AKClassNode *classNode = [_database classWithName:@"NSObject"];
    [self jumpToTopic:[AKClassTopic topicWithClassNode:classNode]];
}

- (void)_setUpViewControllers
{
    // Topic browser.
    _topicBrowserController = [[AK_TopicBrowserViewController alloc] initWithNibName:@"TopicBrowserView"
                                                                              bundle:nil];
    [self _plugVC:_topicBrowserController atView:_topicBrowserView];

//    // Subtopics list.
//    _subtopicListController = [[AK_SubtopicListViewController alloc] initWithNibName:@"SubtopicListView"
//                                                                              bundle:nil];
//    [self _plugVC:_subtopicListController atView:_subtopicListView];
//
//    // Doc list.
//    _docListController = [[AK_DocListViewController alloc] initWithNibName:@"DocListView"
//                                                                    bundle:nil];
//    [self _plugVC:_docListController atView:_docListView];
//
//    // Doc view.
//    _docViewController = [[AK_DocViewController alloc] initWithNibName:@"DocView"
//                                                                bundle:nil];
//    [self _plugVC:_docViewController atView:_docView];




    [[_topicBrowserController topicBrowser] loadColumnZero];
}

- (void)_plugVC:(AK_ViewController *)vc atView:(NSView *)placeholderView
{
    [[vc view] setAutoresizingMask:[placeholderView autoresizingMask]];
    [[placeholderView superview] replaceSubview:placeholderView with:[vc view]];

    // Patch the vc into the responder chain.
    // [agl] do I need to unpatch on dealloc?
    NSResponder *nextResponder = [self nextResponder];
    [self setNextResponder:vc];
    [vc setNextResponder:nextResponder];
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
    BOOL isValid = [self validateItem:theItem];

    if (isValid && ([theItem action] == @selector(jumpToSuperclass:)))
    {
        [theItem setToolTip:[self _tooltipForJumpToSuperclass]];
    }

    return isValid;
}

#pragma mark -
#pragma mark NSSplitView delegate methods

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification
{
    if ([aNotification object] == _topLevelSplitView)
    {
        CGFloat browserHeight = [_topicBrowserView frame].size.height;

        if (browserHeight != 0.0)
        {
            _browserFractionWhenVisible = [self _computeBrowserFraction];
        }
    }
}

#pragma mark -
#pragma mark NSWindow delegate methods

// FIXME [agl] this is a workaround to either a bug or something I don't
// understand; when the prefs panel is dismissed, the AppKiDo window below
// it doesn't come front (despite becoming key) if there was an intervening
// window from another app; weird because if change the prefs panel to an
// NSWindow, it works as expected; anyway, this kludge forces the window
// front when it becomes key
- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
    [(NSWindow *)[aNotification object] orderFront:nil];
}

#pragma mark -
#pragma mark Private methods

- (void)_initToolbar
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:_AKToolbarID];

    // Set up toolbar properties. 
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];

    // We are the delegate.
    [toolbar setDelegate:self];

    // Attach the toolbar to the browser window.
    [[self window] setToolbar:toolbar];
}

- (NSString *)_tooltipForJumpToSuperclass
{
    return [NSString stringWithFormat:@"Go to superclass (%@)"
            @"\n(Control-click or right-click for menu)",
            [[[self _currentTopic] parentClassOfTopic] nodeName]];
}

- (void)_refreshNavigationButtons
{
    [self _refreshBackButton];
    [self _refreshForwardButton];
    [self _refreshSuperclassButton];
}

- (void)_refreshBackButton
{
    NSInteger i;

    // Enable or disable the Back button as appropriate.
    [_backButton setEnabled:(_windowHistoryIndex > 0)];

    // Empty the Back button's contextual menu.
    while ([_backMenu numberOfItems] > 0)
    {
        [_backMenu removeItemAtIndex:0];
    }

    // Reconstruct the Back button's contextual menu.
    for (i = _windowHistoryIndex - 1; i >= 0; i--)
    {
        AKDocLocator *historyItem = [_windowHistory objectAtIndex:i];
        NSString *menuItemName = [historyItem stringToDisplayInLists];

        if (menuItemName)
        {
            [_backMenu addItemWithTitle:menuItemName
                                 action:@selector(doBackMenuAction:)
                          keyEquivalent:@""];
        }
    }
}

- (void)_refreshForwardButton
{
    NSInteger historySize = (int)[_windowHistory count];
    NSInteger i;

    // Enable or disable the Forward button as appropriate.
    [_forwardButton setEnabled:(_windowHistoryIndex < historySize - 1)];

    // Empty the Forward button's contextual menu.
    while ([_forwardMenu numberOfItems] > 0)
    {
        [_forwardMenu removeItemAtIndex:0];
    }

    // Reconstruct the Forward button's contextual menu.
    for (i = _windowHistoryIndex + 1; i < historySize; i++)
    {
        AKDocLocator *historyItem = [_windowHistory objectAtIndex:i];
        NSString *menuItemName = [historyItem stringToDisplayInLists];

        [_forwardMenu addItemWithTitle:menuItemName
                                action:@selector(doForwardMenuAction:)
                         keyEquivalent:@""];
    }
}

- (void)_refreshSuperclassButton
{
    AKClassNode *parentClass = [[self _currentTopic] parentClassOfTopic];

    // Enable or disable the Superclass button as appropriate.
    [_superclassButton setEnabled:(parentClass != nil)];
    if ([_superclassButton isEnabled])
    {
        [_superclassButton setToolTip:[self _tooltipForJumpToSuperclass]];
    }

    // Empty the Superclass button's contextual menu.
    while ([_superclassesMenu numberOfItems] > 0)
    {
        [_superclassesMenu removeItemAtIndex:0];
    }

    // Reconstruct the Superclass button's contextual menu.
    AKClassNode *ancestorNode = parentClass;
    while (ancestorNode != nil)
    {
        [_superclassesMenu addItemWithTitle:[ancestorNode nodeName]
                                     action:@selector(jumpToAncestorClass:)
                              keyEquivalent:@""];

        ancestorNode = [ancestorNode parentClass];
    }
}

// All the history navigation methods come through here.
- (void)_navigateToHistoryIndex:(NSInteger)historyIndex
{
    if ((historyIndex < 0) || (historyIndex >= (NSInteger)[_windowHistory count]))
    {
        return;
    }

    // Navigate to the specified history item.
    AKDocLocator *historyItem = [_windowHistory objectAtIndex:historyIndex];

    [self _rememberCurrentTextSelection];
    [_topicBrowserController navigateFrom:nil to:historyItem];

    // Update our marker index into the history array.
    _windowHistoryIndex = historyIndex;
    DIGSLogDebug(@"jumped to history index %ld, history count=%ld",
                 (long)_windowHistoryIndex, (long)[_windowHistory count]);

    // Update miscellaneous parts of the UI that reflect our current
    // position in history.
    [self _refreshNavigationButtons];
    [[self window] setTitle:[historyItem stringToDisplayInLists]];
}

- (void)_addHistoryItem:(AKDocLocator *)newHistoryItem
{
    AKDocLocator *currentHistoryItem = [self currentHistoryItem];
    NSInteger maxHistory = [AKPrefUtils intValueForPref:AKMaxHistoryPrefName];

    if ([currentHistoryItem isEqual:newHistoryItem])
    {
        return;
    }

    // Trim history beyond our max memory.
    while ((int)[_windowHistory count] > maxHistory - 1)
    {
        [_windowHistory removeObjectAtIndex:0];
        if (_windowHistoryIndex >= 0)
        {
            _windowHistoryIndex--;
        }
    }

    // Trim history items ahead of where the current one is.
    // Remember -count returns an *unsigned* int!
    if (_windowHistoryIndex >= 0)
    {
        while ((int)[_windowHistory count] > _windowHistoryIndex + 1)
        {
            [_windowHistory removeLastObject];
        }
    }

    // Add the current navigation state to the navigation history.
    [_windowHistory addObject:newHistoryItem];
    _windowHistoryIndex = [_windowHistory count] - 1;
    DIGSLogDebug(@"added history item [%@][%@][%@] at index %ld",
                 [[newHistoryItem topicToDisplay] pathInTopicBrowser],
                 [newHistoryItem subtopicName],
                 [newHistoryItem docName],
                 (long)_windowHistoryIndex);

    // Any time the history changes, we want to do the following UI updates.
    [self _refreshNavigationButtons];
    [[self window] setTitle:[newHistoryItem stringToDisplayInLists]];
}

- (AKTopic *)_currentTopic
{
    return [[self currentHistoryItem] topicToDisplay];
}

- (CGFloat)_computeBrowserFraction
{
    CGFloat browserHeight = [_topicBrowserView frame].size.height;

    if (browserHeight == 0.0)
    {
        return 0.0;
    }
    else
    {
        CGFloat splitViewHeight = [_topLevelSplitView frame].size.height - [_topLevelSplitView dividerThickness];

        return browserHeight / splitViewHeight;
    }
}

- (CGFloat)_computeBrowserHeight
{
    CGFloat splitViewHeight = [_topLevelSplitView frame].size.height - [_topLevelSplitView dividerThickness];

    return _browserFractionWhenVisible * splitViewHeight;
}

- (void)_rememberCurrentTextSelection
{
// [agl] fill this in -- put text selection in history dictionary
}

@end
