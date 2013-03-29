/*
 * AKWindowController.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKWindowController.h"

#import "DIGSLog.h"

#import "AKAppDelegate.h"
#import "AKBrowser.h"
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
#import "AKPrefUtils.h"
#import "AKProtocolTopic.h"
#import "AKQuicklistViewController.h"
#import "AKSavedWindowState.h"
#import "AKSubtopicListViewController.h"
#import "AKTabChain.h"
#import "AKTableView.h"
#import "AKTestDocParserWindowController.h"
#import "AKTopicBrowserViewController.h"
#import "AKWindow.h"
#import "AKWindowLayout.h"

#import "NSObject+AppKiDo.h"
#import "NSView+AppKiDo.h"

@implementation AKWindowController

@synthesize topLevelSplitView = _topLevelSplitView;
@synthesize bottomTwoThirdsSplitView = _bottomTwoThirdsSplitView;
@synthesize middleView = _middleView;
@synthesize middleThirdSplitView = _middleThirdSplitView;

@synthesize topicBrowserContainerView = _topicBrowserContainerView;
@synthesize subtopicListContainerView = _subtopicListContainerView;
@synthesize docListContainerView = _docListContainerView;
@synthesize docContainerView = _docContainerView;

@synthesize topicDescriptionField = _topicDescriptionField;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize superclassButton = _superclassButton;
@synthesize backMenu = _backMenu;
@synthesize forwardMenu = _forwardMenu;
@synthesize superclassesMenu = _superclassesMenu;

@synthesize docCommentField = _docCommentField;

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

- (AKDocLocator *)currentDocLocator
{
    return ((_windowHistoryIndex < 0)
            ? nil
            : [_windowHistory objectAtIndex:_windowHistoryIndex]);
}

#pragma mark -
#pragma mark Navigation

- (void)selectTopic:(AKTopic *)obj
{
    AKDocLocator *selectedDocLocator = [self currentDocLocator];

    [self _selectTopic:obj
          subtopicName:[selectedDocLocator subtopicName]
               docName:[selectedDocLocator docName]
          addToHistory:YES];
}

- (void)selectSubtopicWithName:(NSString *)subtopicName
{
    AKDocLocator *selectedDocLocator = [self currentDocLocator];

    [self _selectTopic:[selectedDocLocator topicToDisplay]
          subtopicName:subtopicName
               docName:[selectedDocLocator docName]
          addToHistory:YES];
}

- (void)selectDocWithName:(NSString *)docName
{
    AKDocLocator *selectedDocLocator = [self currentDocLocator];

    [self _selectTopic:[selectedDocLocator topicToDisplay]
          subtopicName:[selectedDocLocator subtopicName]
               docName:docName
          addToHistory:YES];
}

- (void)selectDocWithDocLocator:(AKDocLocator *)docLocator
{
    [self _selectTopic:[docLocator topicToDisplay]
          subtopicName:[docLocator subtopicName]
               docName:[docLocator docName]
          addToHistory:YES];
}

- (BOOL)followLinkURL:(NSURL *)linkURL
{
    // Interpret the link URL as relative to the current doc URL.
    NSString *currentDocFilePath = [[[[self currentDocLocator] docToDisplay] fileSection] filePath];
    NSURL *currentDocFileURL = [NSURL fileURLWithPath:currentDocFilePath];
    NSURL *destinationURL = [NSURL URLWithString:[linkURL relativeString] relativeToURL:currentDocFileURL];

    // If we have a file: URL, try to derive a doc locator from it.
    AKDocLocator *destinationDocLocator = nil;
    
    if ([destinationURL isFileURL])
    {
        AKLinkResolver *linkResolver = [AKLinkResolver linkResolverWithDatabase:_database];
        destinationDocLocator = [linkResolver docLocatorForURL:destinationURL];
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
    [savedWindowState setSavedDocLocator:[self currentDocLocator]];
}

- (NSView *)docView
{
    return [_docViewController docView];
}

- (void)revealPopQuizSymbol:(NSString *)apiSymbol
{
    [_quicklistController includeEverythingInSearch];
    [_quicklistController searchForString:apiSymbol];

    // When the symbol is a "globals" name, it is typically one of many globals
    // in the same doc. We do a Find Next so the doc view will highlight it.
    // Example: NSXMLParserInvalidConditionalSectionError -- it's in the middle
    // of the page, so we need this kludge to scroll the web view down.
    if ([[[self currentDocLocator] topicToDisplay] isKindOfClass:[AKGlobalsTopic class]])
    {
        [self performSelector:@selector(_popQuizKludge) withObject:nil afterDelay:0];
    }
}

- (void)_popQuizKludge
{
    [[AKFindPanelController sharedInstance] findNextFindString:nil];
    [[[_quicklistDrawer contentView] window] makeFirstResponder:[_quicklistController quicklistTable]];
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
    if ([self _topicBrowserIsVisible])
    {
        // Remember the height of the topic browser so we can restore it if its
        // visibility gets toggled back.
        _browserHeightWhenVisible = [_topicBrowserContainerView frame].size.height;

        // Collapse the topic browser.
        [self _setTopSubviewHeight:0
               forTwoPaneSplitView:_topLevelSplitView
                           animate:YES];

        // If the browser had focus, select the next view in the tab chain.
        id firstResponder = [[self window] firstResponder];
        if ([firstResponder isKindOfClass:[NSView class]]
            && [(NSView *)firstResponder isDescendantOf:_topicBrowserContainerView])
        {
            (void)[AKTabChain stepThroughTabChainInWindow:[self window] forward:YES];
        }
    }
    else
    {
        // Expand the topic browser.
        [self _setTopSubviewHeight:_browserHeightWhenVisible
               forTwoPaneSplitView:_topLevelSplitView
                           animate:YES];
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
        [self _showBrowser];
    }
}

- (IBAction)selectInformalProtocolsTopic:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]])
    {
        NSString *frameworkName = [[sender menu] title];

        [self selectTopic:[AKInformalProtocolsTopic topicWithFrameworkNamed:frameworkName
                                                                 inDatabase:_database]];
        [self _showBrowser];
    }
}

- (IBAction)selectFunctionsTopic:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]])
    {
        NSString *frameworkName = [[sender menu] title];

        [self selectTopic:[AKFunctionsTopic topicWithFrameworkNamed:frameworkName
                                                         inDatabase:_database]];
        [self _showBrowser];
    }
}

- (IBAction)selectGlobalsTopic:(id)sender
{
    if ([sender isKindOfClass:[NSMenuItem class]])
    {
        NSString *frameworkName = [[sender menu] title];

        [self selectTopic:[AKGlobalsTopic topicWithFrameworkNamed:frameworkName
                                                       inDatabase:_database]];
        [self _showBrowser];
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

#pragma mark -
#pragma mark Action methods -- accessing the doc file

- (IBAction)copyDocFileURL:(id)sender
{
    NSURL *docURL = [self _currentDocURL];

    if (docURL)
    {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];

        [pasteboard declareTypes:@[NSStringPboardType] owner:nil];
        [pasteboard setString:[docURL absoluteString] forType:NSStringPboardType];
    }
}

- (IBAction)copyDocFilePath:(id)sender
{
    NSString *docPath = [self _currentDocPath];

    if (docPath)
    {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];

        [pasteboard declareTypes:@[NSStringPboardType] owner:nil];
        [pasteboard setString:docPath forType:NSStringPboardType];
    }
}

- (IBAction)openDocFileInBrowser:(id)sender
{
    NSURL *docURL = [self _currentDocURL];

    if (docURL)
    {
        [[NSWorkspace sharedWorkspace] openURL:docURL];
    }
}

- (IBAction)revealDocFileInFinder:(id)sender
{
    NSString *docPath = [self _currentDocPath];

    if (docPath == nil)
    {
        return;
    }

    NSString *containingDirPath = [docPath stringByDeletingLastPathComponent];
    [[NSWorkspace sharedWorkspace] selectFile:docPath
                     inFileViewerRootedAtPath:containingDirPath];
}

#pragma mark -
#pragma mark Action methods -- debugging

- (IBAction)openParseDebugWindow:(id)sender
{
    NSString *docPath = [self _currentDocPath];

    if (docPath)
    {
        [[AKTestDocParserWindowController openNewParserWindow] parseFileAtPath:docPath];
    }
}

- (IBAction)printFunFacts:(id)sender
{
    NSLog(@"FUN FACTS about %@", self);
    NSLog(@"  TopicBrowserController -- %@", [_topicBrowserController ak_bareDescription]);
    NSLog(@"  SubtopicListController -- %@", [_subtopicListController ak_bareDescription]);
    NSLog(@"       DocListController -- %@", [_docListController ak_bareDescription]);
    NSLog(@"       DocViewController -- %@", [_docViewController ak_bareDescription]);
    NSLog(@"     QuicklistController -- %@", [_quicklistController ak_bareDescription]);
    NSLog(@"----");
    NSLog(@"         window -- %@", [[self window] ak_bareDescription]);
    NSLog(@"  topic browser -- %@", [[_topicBrowserController topicBrowser] ak_bareDescription]);
    NSLog(@"  subtopic list -- %@", [[_subtopicListController subtopicsTable] ak_bareDescription]);
    NSLog(@"       doc list -- %@", [[_docListController docListTable] ak_bareDescription]);
    NSLog(@"       web view -- %@", [[_docViewController webView] ak_bareDescription]);
    NSLog(@"      text view -- %@", [[_docViewController textView] ak_bareDescription]);
    NSLog(@"   search field -- %@", [[_quicklistController searchField] ak_bareDescription]);
    NSLog(@"      quicklist -- %@", [[_quicklistController quicklistTable] ak_bareDescription]);
    NSLog(@"END FUN FACTS about %@\n\n", self);
}

#pragma mark -
#pragma mark AKTabChainWindowDelegate methods

- (NSArray *)tabChainViewsForWindow:(NSWindow *)window
{
    NSMutableArray *tabChain = [NSMutableArray array];

    [tabChain addObject:[_topicBrowserController topicBrowser]];

    if ([NSApp isFullKeyboardAccessEnabled])
    {
        [tabChain addObject:_superclassButton];
        [tabChain addObject:_backButton];
        [tabChain addObject:_forwardButton];
    }

    [tabChain addObject:[_subtopicListController subtopicsTable]];
    [tabChain addObject:[_docListController docListTable]];
    [tabChain addObject:[_docViewController docView]];

    if ([_quicklistDrawer state] == NSDrawerOpenState)
    {
        [self _addDrawerControlsToTabChain:tabChain];
    }

    return tabChain;
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

    // Figure out the browser height indicated by windowLayout. If an explicit
    // height is given, use that. Otherwise, use the fraction to calculate it.
    CGFloat browserFraction = [windowLayout browserFraction];
    CGFloat browserHeight = ([windowLayout browserHeight] > 0
                             ? [windowLayout browserHeight]
                             : [self _heightByTakingFraction:browserFraction
                                                 ofSplitView:_topLevelSplitView]);
    _browserHeightWhenVisible = browserHeight;

    // Apply the indicated height to the topic browser.
    if ([self _topicBrowserIsVisible]
        && [windowLayout browserIsVisible])
    {
        [self _setTopSubviewHeight:_browserHeightWhenVisible
               forTwoPaneSplitView:_topLevelSplitView
                           animate:NO];
    }
    else
    {
        [self _setTopSubviewHeight:0
               forTwoPaneSplitView:_topLevelSplitView
                           animate:NO];
    }

    // Restore the state of the bottom two thirds.
    [self _setTopSubviewHeight:[windowLayout middleViewHeight]
           forTwoPaneSplitView:_bottomTwoThirdsSplitView
                       animate:NO];

    if ([windowLayout subtopicListWidth])
    {
        [self _setLeftSubviewWidth:[windowLayout subtopicListWidth]
               forTwoPaneSplitView:_middleThirdSplitView
                           animate:NO];
    }

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
    [windowLayout setSubtopicListWidth:([_subtopicListContainerView frame].size.width)];

    // Remember the state of the topic browser.
    [windowLayout setBrowserIsVisible:[self _topicBrowserIsVisible]];
    [windowLayout setBrowserFraction:[self _fractionByComparingHeight:_browserHeightWhenVisible
                                                  toHeightOfSplitView:_topLevelSplitView]];
    [windowLayout setBrowserHeight:_browserHeightWhenVisible];
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
#pragma mark NSUserInterfaceValidations methods

- (BOOL)validateUserInterfaceItem:(id)anItem
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
    else if (itemAction == @selector(selectSuperclass:))
    {
        BOOL isValid = ([[self _currentTopic] parentClassOfTopic] != nil);

        if (isValid && [anItem isKindOfClass:[NSToolbarItem class]])
        {
            [anItem setToolTip:[self _tooltipForSelectSuperclass]];
        }

        return isValid;
    }
    else if (itemAction == @selector(selectAncestorClass:))
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
            NSString *topicName = [currentTopic stringToDisplayInLists];
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
        if ([anItem isKindOfClass:[NSMenuItem class]])
        {
            if (![self _topicBrowserIsVisible]
                && (_browserHeightWhenVisible > 0.0))
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
    else if ((itemAction == @selector(copyDocFileURL:))
             || (itemAction == @selector(copyDocFilePath:))
             || (itemAction == @selector(openDocFileInBrowser:))
             || (itemAction == @selector(revealDocFileInFinder:))
             || (itemAction == @selector(openParseDebugWindow:)))
    {
        return ([self currentDocLocator] != nil);
    }
    else
    {
        return NO;
    }
}

#pragma mark -
#pragma mark NSWindowController methods

- (void)windowDidLoad
{
    // Load our view controllers and plug their views into the UI. Do this
    // early, because a number of things we do next assume the view controllers
    // have been loaded.
    [self _setUpViewControllers];

    // Add our toolbar. [agl] Is it worth doing this in the nib now that we can?
    [self _setUpToolbar];

    // Apply display preferences specified in the defaults database.
    [self applyUserPreferences];

    // Make the navigation popups use small fonts. I determined empirically that
    // 11 is the size Cocoa uses for small menus.
    NSFont *smallMenuFont = [NSFont menuFontOfSize:11];

    [_superclassesMenu setFont:smallMenuFont];
    [_backMenu setFont:smallMenuFont];
    [_forwardMenu setFont:smallMenuFont];

    // Select NSObject in the topic browser.
    _windowHistoryIndex = -1;
    [_windowHistory removeAllObjects];

    AKClassNode *classNode = [_database classWithName:@"NSObject"];
    [self selectTopic:[AKClassTopic topicWithClassNode:classNode]];

    // Start with the topic browser having focus.
    [[self window] makeFirstResponder:[_topicBrowserController topicBrowser]];
}

#pragma mark -
#pragma mark NSSplitView delegate methods

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
    // As it happens, we want the first subview of all our split views to stay
    // fixed-sized.
    return (subview != [[splitView subviews] objectAtIndex:0]);
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

// "If you want the closing of a window to make both window and window controller go away when it isn’t part of a document, your subclass of NSWindowController can observe the NSWindowWillCloseNotification notification or, as the window delegate, implement the windowWillClose: method."
// http://developer.apple.com/library/Mac/documentation/Cocoa/Conceptual/WinPanel/Concepts/UsingWindowController.html
- (void)windowWillClose:(NSNotification *)aNotification
{
    [self autorelease];
}

#pragma mark -
#pragma mark Private methods

- (void)_setUpViewControllers
{
    // Populate our various container views.
    _topicBrowserController = [[self _vcWithClass:[AKTopicBrowserViewController class]
                                          nibName:@"TopicBrowserView"
                                    containerView:_topicBrowserContainerView] retain];
    _subtopicListController = [[self _vcWithClass:[AKSubtopicListViewController class]
                                          nibName:@"SubtopicListView"
                                    containerView:_subtopicListContainerView] retain];
    _docListController = [[self _vcWithClass:[AKDocListViewController class]
                                     nibName:@"DocListView"
                               containerView:_docListContainerView] retain];
    _docViewController = [[self _vcWithClass:[AKDocViewController class]
                                              nibName:@"DocView"
                                        containerView:_docContainerView] retain];
    _quicklistController = [[self _vcWithClass:[AKQuicklistViewController class]
                                       nibName:@"QuicklistView"
                                 containerView:[_quicklistDrawer contentView]] retain];

    // Load the window with initial data.
    AKBrowser *topicBrowser = [_topicBrowserController topicBrowser];
    
    [topicBrowser loadColumnZero];
    [[self window] setInitialFirstResponder:topicBrowser];
    (void)[[self window] makeFirstResponder:topicBrowser];
}

- (void)_setUpToolbar
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

- (NSString *)_tooltipForSelectSuperclass
{
    return [NSString stringWithFormat:(@"Go to superclass (%@)"
                                       @"\n(Control-click or right-click for menu)"),
            [[[self _currentTopic] parentClassOfTopic] nodeName]];
}

- (void)_refreshNavigationButtons
{
    [self _refreshBackButton];
    [self _refreshForwardButton];
    [self _refreshSuperclassButton];
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
                                 action:@selector(goToHistoryItemInBackMenu:)
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

- (void)_selectTopic:(AKTopic *)topic
        subtopicName:(NSString *)subtopicName
             docName:(NSString *)docName
        addToHistory:(BOOL)shouldAddToHistory
{
    if (topic == nil)
    {
        DIGSLogInfo(@"can't navigate to a nil topic");
        return;
    }

    AKDocLocator *newHistoryItem = [AKDocLocator withTopic:topic
                                              subtopicName:subtopicName
                                                   docName:docName];

    [_topicBrowserController goFromDocLocator:[self currentDocLocator] toDocLocator:newHistoryItem];
    [_subtopicListController goFromDocLocator:[self currentDocLocator] toDocLocator:newHistoryItem];

    [_docListController setSubtopic:[_subtopicListController selectedSubtopic]];
    [_docListController goFromDocLocator:[self currentDocLocator] toDocLocator:newHistoryItem];

    [_docViewController goFromDocLocator:[self currentDocLocator] toDocLocator:newHistoryItem];

    [_topicDescriptionField setStringValue:[topic stringToDisplayInDescriptionField]];
    [_docCommentField setStringValue:[_docListController docComment]];

    if (shouldAddToHistory)
    {
        [self _addHistoryItem:newHistoryItem];
    }
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

    [self _selectTopic:[historyItem topicToDisplay]
          subtopicName:[historyItem subtopicName]
               docName:[historyItem docName]
          addToHistory:NO];

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
    AKDocLocator *currentHistoryItem = [self currentDocLocator];
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

- (NSString *)_currentDocPath
{
    return [[[[self currentDocLocator] docToDisplay] fileSection] filePath];
}

- (NSURL *)_currentDocURL
{
    NSString *docPath = [self _currentDocPath];

    if (docPath == nil)
    {
        return nil;
    }

    return [[[NSURL fileURLWithPath:docPath] absoluteURL] standardizedURL];
}

- (AKTopic *)_currentTopic
{
    return [[self currentDocLocator] topicToDisplay];
}

- (void)_showBrowser
{
    if (![self _topicBrowserIsVisible])
    {
        [self toggleBrowserVisible:nil];
    }
}

- (BOOL)_topicBrowserIsVisible
{
    return ([_topicBrowserContainerView frame].size.height > 0);
}

// Assumes the split view has two subviews, one above the other.
- (void)_setTopSubviewHeight:(CGFloat)newHeight
         forTwoPaneSplitView:(NSSplitView *)splitView
                     animate:(BOOL)shouldAnimate
{
    NSView *viewOne = [[splitView subviews] objectAtIndex:0];
    NSRect frameOne = [viewOne frame];
    NSView *viewTwo = [[splitView subviews] objectAtIndex:1];
    NSRect frameTwo = [viewTwo frame];

    frameOne.size.height = newHeight;
    frameTwo.size.height = ([splitView bounds].size.height
                            - [splitView dividerThickness]
                            - newHeight);
    if (shouldAnimate)
    {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0.1];
        {{
            [[viewOne animator] setFrame:frameOne];
            [[viewTwo animator] setFrame:frameTwo];
        }}
        [NSAnimationContext endGrouping];
    }
    else
    {
        [viewOne setFrame:frameOne];
        [viewTwo setFrame:frameTwo];
    }
}

// Assumes the split view has two subviews, side by side.
- (void)_setLeftSubviewWidth:(CGFloat)newWidth
         forTwoPaneSplitView:(NSSplitView *)splitView
                     animate:(BOOL)shouldAnimate
{
    NSView *viewOne = [[splitView subviews] objectAtIndex:0];
    NSRect frameOne = [viewOne frame];
    NSView *viewTwo = [[splitView subviews] objectAtIndex:1];
    NSRect frameTwo = [viewTwo frame];

    frameOne.size.width = newWidth;
    frameTwo.size.width = ([splitView bounds].size.width
                           - [splitView dividerThickness]
                           - newWidth);
    if (shouldAnimate)
    {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0.1];
        {{
            [[viewOne animator] setFrame:frameOne];
            [[viewTwo animator] setFrame:frameTwo];
        }}
        [NSAnimationContext endGrouping];
    }
    else
    {
        [viewOne setFrame:frameOne];
        [viewTwo setFrame:frameTwo];
    }
}

- (CGFloat)_fractionByComparingHeight:(CGFloat)height toHeightOfSplitView:(NSSplitView *)splitView
{
    NSInteger numberOfDividers = [[splitView subviews] count] - 1;
    CGFloat totalHeightOfSubviews = ([splitView frame].size.height
                                     - numberOfDividers*[splitView dividerThickness]);
    return height / totalHeightOfSubviews;
}

- (CGFloat)_heightByTakingFraction:(CGFloat)fraction ofSplitView:(NSSplitView *)splitView
{
    NSInteger numberOfDividers = [[splitView subviews] count] - 1;
    CGFloat totalHeightOfSubviews = ([splitView frame].size.height
                                     - numberOfDividers*[splitView dividerThickness]);
    return fraction * totalHeightOfSubviews;
}


- (void)_addDrawerControlsToTabChain:(NSMutableArray *)tabChain
{
    if ([NSApp isFullKeyboardAccessEnabled])
    {
        [tabChain addObject:[_quicklistController quicklistRadio1]];
        [tabChain addObject:[_quicklistController quicklistRadio2]];
        [tabChain addObject:[_quicklistController frameworkPopup]];
        [tabChain addObject:[_quicklistController quicklistRadio3]];
    }

    [tabChain addObject:[_quicklistController searchField]];

    if ([NSApp isFullKeyboardAccessEnabled])
    {
        [tabChain addObject:[_quicklistController searchOptionsPopup]];
    }

    [tabChain addObject:[_quicklistController quicklistTable]];

    if ([NSApp isFullKeyboardAccessEnabled])
    {
        [tabChain addObject:[_quicklistController removeFavoriteButton]];
    }
}

@end
