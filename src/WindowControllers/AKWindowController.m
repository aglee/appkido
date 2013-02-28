/*
 * AKBrowserWindowController.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKWindowController.h"

#import "DIGSLog.h"

#import "AKAppDelegate.h"
#import "AKClassNode.h"
#import "AKClassTopic.h"
#import "AKDatabase.h"
#import "AKDoc.h"
#import "AKDocListViewController.h"
#import "AKDocLocator.h"
#import "AKDocViewController.h"
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
#import "AKQuicklistViewController.h"
#import "AKSavedWindowState.h"
#import "AKSubtopicListViewController.h"
#import "AKTopicBrowserViewController.h"
#import "AKViewUtils.h"
#import "AKWindowLayout.h"

@implementation AKWindowController

@synthesize topLevelSplitView = _topLevelSplitView;
@synthesize innerSplitView = _innerSplitView;
@synthesize middleView = _middleView;

@synthesize topicBrowserContainerView = _topicBrowserContainerView;
@synthesize subtopicListContainerView = _subtopicListContainerView;
@synthesize docListContainerView = _docListContainerView;
@synthesize docContainerView = _docContainerView;

@synthesize docCommentField = _docCommentField;

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

    [super dealloc];
}

#pragma mark -
#pragma mark Getters and setters

- (AKDatabase *)database
{
    return _database;
}

- (AKDoc *)currentDoc
{
    AKDocLocator *docLocator = [self _currentDocLocator];
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
    AKDocLocator *docLocator = [self _currentDocLocator];
    AKDoc *currentDoc = [docLocator docToDisplay];
    
    if (currentDoc == nil)
    {
        docLocator = [AKDocLocator withTopic:[docLocator topicToDisplay]
                                subtopicName:@"General"
                                     docName:@"Overview"];
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

- (void)selectTopic:(AKTopic *)obj
{
    AKDocLocator *selectedDocLocator = [self _currentDocLocator];

    [self _selectTopic:obj
          subtopicName:[selectedDocLocator subtopicName]
               docName:[selectedDocLocator docName]];
}

- (void)selectSubtopicWithName:(NSString *)subtopicName
{
    AKDocLocator *selectedDocLocator = [self _currentDocLocator];

    [self _selectTopic:[selectedDocLocator topicToDisplay]
          subtopicName:subtopicName
               docName:[selectedDocLocator docName]];
}

- (void)selectDocWithName:(NSString *)docName
{
    AKDocLocator *selectedDocLocator = [self _currentDocLocator];

    [self _selectTopic:[selectedDocLocator topicToDisplay]
          subtopicName:[selectedDocLocator subtopicName]
               docName:docName];
}

- (void)selectDocWithDocLocator:(AKDocLocator *)docLocator
{
    [self _selectTopic:[docLocator topicToDisplay]
          subtopicName:[docLocator subtopicName]
               docName:[docLocator docName]];
}

- (BOOL)followLinkURL:(NSURL *)linkURL
{
    // Interpret the link URL as relative to the current doc URL.
    NSString *currentDocFilePath = [[[[self _currentDocLocator] docToDisplay] fileSection] filePath];
    NSURL *currentDocFileURL = [NSURL fileURLWithPath:currentDocFilePath];
    NSURL *destinationURL = [NSURL URLWithString:[linkURL relativeString] relativeToURL:currentDocFileURL];

    // If we have a file: URL, try to derive a doc locator from it.
    AKDocLocator *destinationDocLocator = nil;
    if (![destinationURL isFileURL])
    {
        AKLinkResolver *linkResolver = [AKLinkResolver linkResolverWithDatabase:_database];
        destinationDocLocator = [linkResolver docLocatorForURL:destinationURL];

        if (destinationDocLocator == nil)
        {
            DIGSLogDebug(@"resorting to AKOldLinkResolver for %@", linkURL);
            linkResolver = [AKOldLinkResolver linkResolverWithDatabase:_database];
            destinationDocLocator = [linkResolver docLocatorForURL:destinationURL];
        }
    }

    // If we derived a doc locator, go to it. Otherwise, try opening the file in
    // the user's browser.
    if (destinationDocLocator)
    {
        [self selectDocWithDocLocator:destinationDocLocator];
        [_docListController focusOnDocListTable];
        [self showWindow:nil];
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

- (void)openQuicklistDrawer
{
    if (([_quicklistDrawer state] != NSDrawerOpenState)
        && ([_quicklistDrawer state] != NSDrawerOpeningState))
    {
        [_quicklistDrawer openOnEdge:NSMinXEdge];
    }
}

- (void)searchForString:(NSString *)aString
{
    [_quicklistController searchForString:aString];
}

- (void)putSavedWindowStateInto:(AKSavedWindowState *)savedWindowState
{
    AKWindowLayout *windowLayout = [[[AKWindowLayout alloc] init] autorelease];

    [self putWindowLayoutInto:windowLayout];

    [savedWindowState setSavedWindowLayout:windowLayout];
    [savedWindowState setSavedDocLocator:[self _currentDocLocator]];
}

- (NSView *)focusOnDocView
{
    return [_docViewController grabFocus];
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

- (IBAction)toggleBrowserVisible:(id)sender
{
    NSRect browserFrame = [_topicBrowserContainerView frame];

    if (browserFrame.size.height == 0.0)
    {
        [_topLevelSplitView ak_setHeight:[self _computeBrowserHeight] ofSubview:_topicBrowserContainerView];
    }
    else
    {
        [_topLevelSplitView ak_setHeight:0.0 ofSubview:_topicBrowserContainerView];
    }

    // [agl] KLUDGE -- for some reason the scroll view does not retile
    // automatically, so I force it here; the reason I traverse all subviews
    // is because the internal view hierarchy of WebView is not exposed
    //
    // [agl] This is a very old kludge. It's possible it isn't needed any more.
    [self _recursivelyTileScrollViews:_docContainerView];
}

- (void)_recursivelyTileScrollViews:(NSView *)view
{
    if ([view isKindOfClass:[NSScrollView class]])
    {
        [(NSScrollView *)view tile];
    }

    for (NSView *subview in [view subviews])
    {
        [self _recursivelyTileScrollViews:subview];
    }
}

- (IBAction)showBrowser:(id)sender
{
    if ([_topicBrowserContainerView frame].size.height == 0.0)
    {
        [self toggleBrowserVisible:nil];
    }
}

- (IBAction)toggleQuicklistDrawer:(id)sender
{
    NSInteger state = [_quicklistDrawer state];

    if ((state == NSDrawerClosedState) || (state == NSDrawerClosingState))
    {
        [self openQuicklistDrawer];
    }
    else
    {
        [_quicklistDrawer close];
    }
}

#pragma mark -
#pragma mark Action methods -- navigation

- (IBAction)goBackInHistory:(id)sender
{
    if (_windowHistoryIndex > 0)
    {
        [self _goToHistoryItemAtIndex:(_windowHistoryIndex - 1)];
    }
}

- (IBAction)goForwardInHistory:(id)sender
{
    if (_windowHistoryIndex < ((int)[_windowHistory count] - 1))
    {
        [self _goToHistoryItemAtIndex:(_windowHistoryIndex + 1)];
    }
}

- (IBAction)goToHistoryItemInBackMenu:(id)sender
{
    NSInteger offset = [_backMenu indexOfItem:(NSMenuItem *)sender] + 1;
    [self _goToHistoryItemAtIndex:(_windowHistoryIndex - offset)];
}

- (IBAction)goToHistoryItemInForwardMenu:(id)sender
{
    NSInteger offset = [_forwardMenu indexOfItem:(NSMenuItem *)sender] + 1;
    [self _goToHistoryItemAtIndex:(_windowHistoryIndex + offset)];
}

- (IBAction)selectSuperclass:(id)sender
{
    AKClassNode *superclassNode = [[self _currentTopic] parentClassOfTopic];

    if (superclassNode)
    {
        [self selectTopic:[AKClassTopic topicWithClassNode:superclassNode]];
    }
}

- (IBAction)selectAncestorClass:(id)sender
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
    [self selectTopic:[AKClassTopic topicWithClassNode:classNode]];
}

- (IBAction)selectFormalProtocolsTopic:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]])
    {
        NSString *frameworkName = [[sender menu] title];

        [self selectTopic:[AKFormalProtocolsTopic topicWithFrameworkNamed:frameworkName
                                                               inDatabase:_database]];
        [self showBrowser:nil];
    }
}

- (IBAction)selectInformalProtocolsTopic:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]])
    {
        NSString *frameworkName = [[sender menu] title];

        [self selectTopic:[AKInformalProtocolsTopic topicWithFrameworkNamed:frameworkName
                                                                 inDatabase:_database]];
        [self showBrowser:nil];
    }
}

- (IBAction)selectFunctionsTopic:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]])
    {
        NSString *frameworkName = [[sender menu] title];

        [self selectTopic:[AKFunctionsTopic topicWithFrameworkNamed:frameworkName
                                                         inDatabase:_database]];
        [self showBrowser:nil];
    }
}

- (IBAction)selectGlobalsTopic:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]])
    {
        NSString *frameworkName = [[sender menu] title];

        [self selectTopic:[AKGlobalsTopic topicWithFrameworkNamed:frameworkName
                                                       inDatabase:_database]];
        [self showBrowser:nil];
    }
}

- (IBAction)selectDocWithDocLocatorRepresentedBy:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]]
        && [[sender representedObject] isKindOfClass:[AKDocLocator class]])
    {
        [self selectDocWithDocLocator:[sender representedObject]];
    }
}

- (IBAction)addTopicToFavorites:(id)sender
{
    AKDocLocator *docLocator = [AKDocLocator withTopic:[self _currentTopic]
                                          subtopicName:nil
                                               docName:nil];
    [(AKAppDelegate *)[NSApp delegate] addFavorite:docLocator];
}

- (IBAction)findNext:(id)sender
{
    [[AKFindPanelController sharedInstance] findNext:nil];
}

- (IBAction)findPrevious:(id)sender
{
    [[AKFindPanelController sharedInstance] findPrevious:nil];
}

#pragma mark -
#pragma mark AKUIController methods

- (void)applyUserPreferences
{
    [_topicBrowserController applyUserPreferences];
    [_subtopicListController applyUserPreferences];
    [_docListController applyUserPreferences];
    [_docViewController applyUserPreferences];
    [_quicklistController applyUserPreferences];
}

- (BOOL)validateItem:(id)anItem
{
    SEL itemAction = [anItem action];

    if (itemAction == @selector(goBackInHistory:))
    {
        return (_windowHistoryIndex > 0);
    }
    else if (itemAction == @selector(goForwardInHistory:))
    {
        return (_windowHistoryIndex < ((int)[_windowHistory count] - 1));
    }
    else if ((itemAction == @selector(goToHistoryItemInBackMenu:))
             || (itemAction == @selector(goToHistoryItemInForwardMenu:)))
    {
        return YES;
    }
    else if ((itemAction == @selector(selectSuperclass:))
             || (itemAction == @selector(selectAncestorClass:)))
    {
        return ([[self _currentTopic] parentClassOfTopic] != nil);
    }
    else if ((itemAction == @selector(selectFormalProtocolsTopic:))
             || (itemAction == @selector(selectInformalProtocolsTopic:))
             || (itemAction == @selector(selectFunctionsTopic:))
             || (itemAction == @selector(selectGlobalsTopic:))
             || (itemAction == @selector(selectDocWithDocLocatorRepresentedBy:))
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
        NSArray *favoritesList = [(AKAppDelegate *)[NSApp delegate] favoritesList];
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
            if (([_topicBrowserContainerView frame].size.height == 0.0)
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
    
    if (([_topicBrowserContainerView frame].size.height > 0.0)
        && [windowLayout browserIsVisible])
    {
        [_topLevelSplitView ak_setHeight:[self _computeBrowserHeight]
                               ofSubview:_topicBrowserContainerView];
    }
    else
    {
        [_topLevelSplitView ak_setHeight:0.0
                               ofSubview:_topicBrowserContainerView];
    }

    // Restore the state of the inner split view.
    [_innerSplitView ak_setHeight:[windowLayout middleViewHeight]
                        ofSubview:_middleView];
    
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

    // Remember the state of the topic browser.
    [windowLayout setBrowserIsVisible:([_topicBrowserContainerView frame].size.height > 0)];
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
    [self selectTopic:[AKClassTopic topicWithClassNode:classNode]];
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

    if (isValid && ([theItem action] == @selector(selectSuperclass:)))
    {
        [theItem setToolTip:[self _tooltipForSelectSuperclass]];
    }

    return isValid;
}

#pragma mark -
#pragma mark NSSplitView delegate methods

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
    // We contain two split views, and we happen to want them both to resize the
    // same way.
    [splitView al_preserveTopHeightOfTwoSubviewsWithOldSize:oldSize];
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification
{
    if ([aNotification object] == _topLevelSplitView)
    {
        CGFloat browserHeight = [_topicBrowserContainerView frame].size.height;

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

- (AKDocLocator *)_currentDocLocator
{
    return ((_windowHistoryIndex < 0)
            ? nil
            : [_windowHistory objectAtIndex:_windowHistoryIndex]);
}

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

- (void)_setUpViewControllers
{
    // Topic browser.
    _topicBrowserController = [[self _vcWithClass:[AKTopicBrowserViewController class]
                                          nibName:@"TopicBrowserView"
                                    containerView:_topicBrowserContainerView] retain];
    // Subtopics list.
    _subtopicListController = [[self _vcWithClass:[AKSubtopicListViewController class]
                                          nibName:@"SubtopicListView"
                                    containerView:_subtopicListContainerView] retain];
    // Doc list.
    _docListController = [[self _vcWithClass:[AKDocListViewController class]
                                     nibName:@"DocListView"
                               containerView:_docListContainerView] retain];
    // Doc view.
    _docViewController = [[self _vcWithClass:[AKDocViewController class]
                                              nibName:@"DocView"
                                        containerView:_docContainerView] retain];
    // Quicklist view.
    _quicklistController = [[self _vcWithClass:[AKQuicklistViewController class]
                                       nibName:@"QuicklistView"
                                 containerView:[_quicklistDrawer contentView]] retain];
    // Initial display.
    [[_topicBrowserController topicBrowser] loadColumnZero];
}

- (id)_vcWithClass:(Class)vcClass
           nibName:(NSString *)nibName
     containerView:(NSView *)containerView
{
    id vc = [[[vcClass alloc] initWithNibName:nibName windowController:self] autorelease];
    
    // Stuff the view controller's view into the container view.
    [[vc view] setFrame:[containerView bounds]];
    [[vc view] setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

    [containerView addSubview:[vc view]];

    // Patch the view controller into the responder chain after self.
    // [agl] do I need to unpatch on dealloc?
    NSResponder *nextResponder = [self nextResponder];
    [self setNextResponder:vc];
    [vc setNextResponder:nextResponder];

    return vc;
}

- (void)_plugVC:(AKViewController *)vc intoContainerView:(NSView *)containerView
{
    // Stuff the view controller's view into the container view.
    if (containerView)
    {
        [[vc view] setFrame:[containerView bounds]];
        [[vc view] setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];

        [containerView addSubview:[vc view]];
    }

    // Patch the vc into the responder chain.
    // [agl] do I need to unpatch on dealloc?
    NSResponder *nextResponder = [self nextResponder];
    [self setNextResponder:vc];
    [vc setNextResponder:nextResponder];
}

- (NSString *)_tooltipForSelectSuperclass
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
                                action:@selector(goToHistoryItemInForwardMenu:)
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
        [_superclassButton setToolTip:[self _tooltipForSelectSuperclass]];
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
                                     action:@selector(selectAncestorClass:)
                              keyEquivalent:@""];

        ancestorNode = [ancestorNode parentClass];
    }
}

- (void)_selectTopic:(AKTopic *)topic
        subtopicName:(NSString *)subtopicName
             docName:(NSString *)docName
{
    if (topic == nil)
    {
        DIGSLogInfo(@"can't navigate to a nil topic");
        return;
    }

    [self _rememberCurrentTextSelection];

    AKDocLocator *newHistoryItem = [AKDocLocator withTopic:topic subtopicName:subtopicName docName:docName];

    [_topicBrowserController goFromDocLocator:[self _currentDocLocator] toDocLocator:newHistoryItem];
    [_subtopicListController goFromDocLocator:[self _currentDocLocator] toDocLocator:newHistoryItem];

    [_docListController setSubtopic:[_subtopicListController selectedSubtopic]];
    [_docListController goFromDocLocator:[self _currentDocLocator] toDocLocator:newHistoryItem];

    [_docViewController goFromDocLocator:[self _currentDocLocator] toDocLocator:newHistoryItem];

    [_topicDescriptionField setStringValue:[topic stringToDisplayInDescriptionField]];
    [_docCommentField setStringValue:[_docListController docComment]];

    [self _addHistoryItem:newHistoryItem];
}

// All the history navigation methods come through here.
- (void)_goToHistoryItemAtIndex:(NSInteger)historyIndex
{
    if ((historyIndex < 0) || (historyIndex >= (NSInteger)[_windowHistory count]))
    {
        return;
    }

    // Navigate to the specified history item.
    AKDocLocator *historyItem = [_windowHistory objectAtIndex:historyIndex];

    [self _rememberCurrentTextSelection];
    [_topicBrowserController goFromDocLocator:nil toDocLocator:historyItem];

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
    AKDocLocator *currentHistoryItem = [self _currentDocLocator];
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
    return [[self _currentDocLocator] topicToDisplay];
}

- (CGFloat)_computeBrowserFraction
{
    CGFloat browserHeight = [_topicBrowserContainerView frame].size.height;

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
