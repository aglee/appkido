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
#import "AKTableView.h"
#import "AKTestDocParserWindowController.h"
#import "AKTopicBrowserViewController.h"
#import "AKWindow.h"
#import "AKWindowLayout.h"

#import "NSObject+AppKiDo.h"
#import "NSSplitView+AppKiDo.h"

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

- (void)recalculateTabChains
{
    AKWindow *w = (AKWindow *)[self window];
    NSMutableArray *tabChain = [NSMutableArray array];

    if ([NSApp isFullKeyboardAccessEnabled] && [[w toolbar] isVisible])
    {
        [self _addToolbarItemsToTabChain:tabChain];
    }
    
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

    [w removeAllTabChains];
    [w addLoopingTabChain:tabChain];
}


//NSView
//	NSToolbarItemViewer
//	NSControl
//		_NSToolbarItemViewerLabelView
//		NSButton
//			NSToolbarButton
//
//
//BEGIN nextKeyView sequence:
//  <NSToolbarButton: 0xd175990>
//  <NSToolbarItemViewer: 0x3967a90>
//  <_NSToolbarItemViewerLabelView: 0x3967c20>
//  <NSToolbarButton: 0xd1763f0>
//  <NSToolbarItemViewer: 0x39681a0>
//  <_NSToolbarItemViewerLabelView: 0x3968350>
//  <NSToolbarButton: 0x39659d0>
//  <NSToolbarItemViewer: 0x3968770>
//  <_NSToolbarItemViewerLabelView: 0x3968920>
//  <NSToolbarButton: 0x3965e00>
//  <NSToolbarView: 0x236c720>
//  <NSToolbarItemViewer: 0x3966210>
//  <_NSToolbarItemViewerLabelView: 0x3966510>
//  <NSToolbarButton: 0x237d870>
//  <NSToolbarItemViewer: 0x39673e0>
//  <_NSToolbarItemViewerLabelView: 0x39676b0>
//  <NSToolbarButton: 0xd175990>
//END nextKeyView sequence -- sequence contains a loop
//
//
//NSThemeFrame
//	<_NSThemeCloseWidget: 0xd1746c0>,
//	<_NSThemeWidget: 0xd172dc0>,
//	<_NSThemeWidget: 0xd1762a0>,
//
//	contentView <NSView: 0xd1b0d70>,
//
//	(<NSToolbarView: 0x236c720>: AKToolbarID)
//		<_NSToolbarViewClipView: 0x232cab0>
//			<NSToolbarItemViewer: 0x3966210 'AKQuicklistToolID'>,
//				<_NSToolbarItemViewerLabelView: 0x3966510>,
//				<NSToolbarButton: 0x237d870>
//			<NSToolbarItemViewer: 0x39673e0 'AKBrowserToolID'>,
//			<NSToolbarItemViewer: 0x3967a90 'AKBackToolID'>,
//			<NSToolbarItemViewer: 0x39681a0 'AKForwardToolID'>,
//			<NSToolbarItemViewer: 0x3968770 'AKSuperclassToolID'>


- (void)_addToolbarItemsToTabChain:(NSMutableArray *)tabChain
{
    NSView *themeFrame = [[[self window] contentView] superview];
    NSView *toolbarView = [[self _subviewsOf:themeFrame
                               withClassName:@"NSToolbarView"] lastObject];
    NSView *toolbarClipView = [[toolbarView subviews] lastObject];

    for (NSView *toolbarItemViewer in [toolbarClipView subviews])
    {
        NSButton *toolbarButton = [[self _subviewsOf:toolbarItemViewer
                                       withClassName:@"NSToolbarButton"] lastObject];
        if ([toolbarButton isEnabled])
        {
            [tabChain addObject:toolbarButton];
        }
    }
}

- (NSArray *)_subviewsOf:(NSView *)view withClassName:(NSString *)viewClassName
{
    NSMutableArray *result = [NSMutableArray array];

    for (NSView *subview in [view subviews])
    {
        if ([[subview className] isEqualToString:viewClassName])
        {
            [result addObject:subview];
        }
    }

    return result;
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
    CGFloat newBrowserHeight = (([_topicBrowserContainerView frame].size.height == 0.0)
                                ? [self _computeBrowserHeight]
                                : 0.0);

    [_topLevelSplitView ak_setHeight:newBrowserHeight ofSubviewAtIndex:0];

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
    else if ((itemAction == @selector(copyDocFileURL:))
             || (itemAction == @selector(copyDocFilePath:))
             || (itemAction == @selector(openDocFileInBrowser:))
             || (itemAction == @selector(revealDocFileInFinder:))
             || (itemAction == @selector(openParseDebugWindow:)))
    {
        return ([self currentDocLocator] != nil);
    }
    else if ([_topicBrowserController validateItem:anItem])
    {
        return YES;
    }
    else if ([_subtopicListController validateItem:anItem])
    {
        return YES;
    }
    else if ([_docListController validateItem:anItem])
    {
        return YES;
    }
    else if ([_docViewController validateItem:anItem])
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

    // Apply the new browser fraction.  Note that -_computeBrowserHeight
    // uses the _browserFractionWhenVisible ivar, so we make sure to set
    // the ivar first.
    _browserFractionWhenVisible = [windowLayout browserFraction];
    
    if (([_topicBrowserContainerView frame].size.height > 0.0)
        && [windowLayout browserIsVisible])
    {
        [_topLevelSplitView ak_setHeight:[self _computeBrowserHeight] ofSubviewAtIndex:0];
    }
    else
    {
        [_topLevelSplitView ak_setHeight:0.0 ofSubviewAtIndex:0];
    }

    // Restore the state of the bottom two thirds.
    [_bottomTwoThirdsSplitView ak_setHeight:[windowLayout middleViewHeight] ofSubviewAtIndex:0];

    if ([windowLayout subtopicListWidth])
    {
        [_middleThirdSplitView ak_setWidth:[windowLayout subtopicListWidth] ofSubviewAtIndex:0];
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

    // Make the navigation popups use small fonts.
    NSFont *smallMenuFont = [NSFont menuFontOfSize:11];
    
    [_superclassesMenu setFont:smallMenuFont];
    [_backMenu setFont:smallMenuFont];
    [_forwardMenu setFont:smallMenuFont];

    // Initialize my view controllers and populate my container views with
    // actual views.
    [self _setUpViewControllers];
    [[self window] recalculateKeyViewLoop];
    [[[_quicklistDrawer contentView] window] recalculateKeyViewLoop];
    [self recalculateTabChains];

    // Apply display preferences *after* all awake-from-nibs have been
    // done, because DIGSMarginViews have to have fully initialized
    // themselves before we go resizing things or swapping subviews around.
    [self applyUserPreferences];

    // Select NSObject in the topic browser.
    _windowHistoryIndex = -1;
    [_windowHistory removeAllObjects];

    AKClassNode *classNode = [_database classWithName:@"NSObject"];
    [self selectTopic:[AKClassTopic topicWithClassNode:classNode]];

    // Start with the topic browser selected.
    [[self window] makeFirstResponder:[_topicBrowserController topicBrowser]];
}

#pragma mark -
#pragma mark NSDrawer delegate methods

- (void)drawerDidOpen:(NSNotification *)notification
{
    [self recalculateTabChains];
}

- (void)drawerDidClose:(NSNotification *)notification
{
    [self recalculateTabChains];
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

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
    // As it happens, we want the first subview of all our split views to stay
    // fixed-sized.
    return (subview != [[splitView subviews] objectAtIndex:0]);
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

// "If you want the closing of a window to make both window and window controller go away when it isn’t part of a document, your subclass of NSWindowController can observe the NSWindowWillCloseNotification notification or, as the window delegate, implement the windowWillClose: method."
// http://developer.apple.com/library/Mac/documentation/Cocoa/Conceptual/WinPanel/Concepts/UsingWindowController.html
- (void)windowWillClose:(NSNotification *)aNotification
{
    [self autorelease];
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

    [self _rememberCurrentTextSelection];

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
