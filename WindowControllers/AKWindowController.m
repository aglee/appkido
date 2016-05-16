/*
 * AKWindowController.m
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKWindowController.h"
#import <WebKit/WebKit.h>
#import "DIGSLog.h"
#import "AKAppDelegate.h"
#import "AKBrowser.h"
#import "AKClassToken.h"
#import "AKClassTopic.h"
#import "AKDatabase.h"
#import "AKDocListViewController.h"
#import "AKDocLocator.h"
#import "AKDocViewController.h"
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

#pragma mark - Private constants -- toolbar identifiers

static NSString *_AKToolbarID = @"AKToolbarID";

#pragma mark - Init/dealloc/awake

- (instancetype)initWithDatabase:(AKDatabase *)database
{
	if ((self = [super initWithWindowNibName:@"AKWindow"])) {
		_database = database;

		NSInteger maxHistory = [AKPrefUtils intValueForPref:AKMaxHistoryPrefName];

		_windowHistory = [[NSMutableArray alloc] initWithCapacity:maxHistory];
		_windowHistoryIndex = -1;
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithDatabase:nil];
}

#pragma mark - Getters and setters

- (AKDatabase *)database
{
	return _database;
}

- (AKDocLocator *)currentDocLocator
{
	return ((_windowHistoryIndex < 0)
			? nil
			: _windowHistory[_windowHistoryIndex]);
}

#pragma mark - Navigation

- (void)selectTopic:(AKTopic *)obj
{
	AKDocLocator *selectedDocLocator = [self currentDocLocator];
	[self _selectTopic:obj
		  subtopicName:selectedDocLocator.subtopicName
			   docName:selectedDocLocator.docName
		  addToHistory:YES];
}

- (void)selectSubtopicWithName:(NSString *)subtopicName
{
	AKDocLocator *selectedDocLocator = [self currentDocLocator];
	[self _selectTopic:selectedDocLocator.topicToDisplay
		  subtopicName:subtopicName
			   docName:selectedDocLocator.docName
		  addToHistory:YES];
}

- (void)selectDocWithName:(NSString *)docName
{
	AKDocLocator *selectedDocLocator = [self currentDocLocator];
	[self _selectTopic:selectedDocLocator.topicToDisplay
		  subtopicName:selectedDocLocator.subtopicName
			   docName:docName
		  addToHistory:YES];
}

- (void)selectDocWithDocLocator:(AKDocLocator *)docLocator
{
	[self _selectTopic:docLocator.topicToDisplay
		  subtopicName:docLocator.subtopicName
			   docName:docLocator.docName
		  addToHistory:YES];
}

- (BOOL)followLinkURL:(NSURL *)linkURL
{
	return YES;
//TODO: Commenting out, come back to this later.
//    // Interpret the link URL as relative to the current doc URL.
//    NSString *currentDocFilePath = [[[[self currentDocLocator] docToDisplay] fileSection] filePath];
//    NSURL *currentDocFileURL = [NSURL fileURLWithPath:currentDocFilePath];
//    NSURL *destinationURL = [NSURL URLWithString:linkURL.relativeString relativeToURL:currentDocFileURL];
//
//    // If we have a file: URL, try to derive a doc locator from it.
//    AKDocLocator *destinationDocLocator = nil;
//
//    if (destinationURL.fileURL)
//    {
//        AKLinkResolver *linkResolver = [AKLinkResolver linkResolverWithDatabase:_database];
//        destinationDocLocator = [linkResolver docLocatorForURL:destinationURL];
//    }
//
//    // If we derived a doc locator, go to it. Otherwise, try opening the file in
//    // the user's browser.
//    if (destinationDocLocator)
//    {
//        [self selectDocWithDocLocator:destinationDocLocator];
//        [_docListController focusOnDocListTable];
//        [self showWindow:nil];
//        return YES;
//    }
//    else if ([[NSWorkspace sharedWorkspace] openURL:destinationURL])
//    {
//        DIGSLogDebug(@"NSWorkspace opened URL [%@]", destinationURL);
//        return YES;
//    }
//    else
//    {
//        DIGSLogWarning(@"NSWorkspace couldn't open URL [%@]", destinationURL);
//        return NO;
//    }
}

- (void)openQuicklistDrawer
{
	if ((_quicklistDrawer.state != NSDrawerOpenState)
		&& (_quicklistDrawer.state != NSDrawerOpeningState)) {

		[_quicklistDrawer openOnEdge:NSMinXEdge];
	}
}

- (void)searchForString:(NSString *)aString
{
	[_quicklistController searchForString:aString];
}

- (void)putSavedWindowStateInto:(AKSavedWindowState *)savedWindowState
{
	AKWindowLayout *windowLayout = [[AKWindowLayout alloc] init];

	[self putWindowLayoutInto:windowLayout];

	savedWindowState.savedWindowLayout = windowLayout;
	savedWindowState.savedDocLocator = [self currentDocLocator];
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
	if ([[self currentDocLocator].topicToDisplay isKindOfClass:[AKGlobalsTopic class]]) {
		[self performSelector:@selector(_popQuizKludge) withObject:nil afterDelay:0];
	}
}

- (void)_popQuizKludge
{
	[[AKFindPanelController sharedInstance] findNextFindString:nil];
	[_quicklistDrawer.contentView.window makeFirstResponder:_quicklistController.quicklistTable];
}

#pragma mark - Action methods -- window layout

- (IBAction)rememberWindowLayout:(id)sender
{
	AKWindowLayout *windowLayout = [[AKWindowLayout alloc] init];
	[self putWindowLayoutInto:windowLayout];

	NSDictionary *prefDictionary = [windowLayout asPrefDictionary];
	[AKPrefUtils setDictionaryValue:prefDictionary forPref:AKLayoutForNewWindowsPrefName];
}

- (IBAction)toggleBrowserVisible:(id)sender
{
	if ([self _topicBrowserIsVisible]) {
		// Remember the height of the topic browser so we can restore it if its
		// visibility gets toggled back.
		_browserHeightWhenVisible = _topicBrowserContainerView.frame.size.height;

		// Collapse the topic browser.
		[self _setTopSubviewHeight:0
			   forTwoPaneSplitView:_topLevelSplitView
						   animate:YES];

		// If the browser had focus, select the next view in the tab chain.
		id firstResponder = self.window.firstResponder;
		if ([firstResponder isKindOfClass:[NSView class]]
			&& [(NSView *)firstResponder isDescendantOf:_topicBrowserContainerView]) {

			(void)[AKTabChain stepThroughTabChainInWindow:self.window forward:YES];
		}
	} else {
		// Expand the topic browser.
		[self _setTopSubviewHeight:_browserHeightWhenVisible
			   forTwoPaneSplitView:_topLevelSplitView
						   animate:YES];
	}
}

- (IBAction)toggleQuicklistDrawer:(id)sender
{
	NSInteger state = _quicklistDrawer.state;
	if ((state == NSDrawerClosedState) || (state == NSDrawerClosingState)) {
		[self openQuicklistDrawer];
	} else {
		[_quicklistDrawer close];
	}
}

#pragma mark - Action methods -- navigation

- (IBAction)goBackInHistory:(id)sender
{
	if (_windowHistoryIndex > 0) {
		[self _goToHistoryItemAtIndex:(_windowHistoryIndex - 1)];
	}
}

- (IBAction)goForwardInHistory:(id)sender
{
	if (_windowHistoryIndex < ((int)_windowHistory.count - 1)) {
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
	AKClassToken *superclassToken = [[self _currentTopic] parentClassOfTopic];
	if (superclassToken) {
		[self selectTopic:[[AKClassTopic alloc] initWithClassToken:superclassToken]];
	}
}

- (IBAction)selectAncestorClass:(id)sender
{
	AKClassToken * classToken = [[self _currentTopic] parentClassOfTopic];
	NSInteger numberOfSuperlevels;
	NSInteger i;

	if (classToken == nil) {
		return;
	}

	// Figure out how far back in our ancestry to jump.
	numberOfSuperlevels = [_superclassesMenu indexOfItem:sender];

	// Figure out what class that means to jump to.
	for (i = 0; i < numberOfSuperlevels; i++) {
		classToken = classToken.parentClass;
	}

	// Do the jump.
	[self selectTopic:[[AKClassTopic alloc] initWithClassToken:classToken]];
}

- (IBAction)selectFormalProtocolsTopic:(id)sender
{
	if ([sender isKindOfClass:[NSMenuItem class]]) {
		NSString *frameworkName = [sender menu].title;
		[self selectTopic:[[AKFormalProtocolsTopic alloc] initWithFramework:frameworkName
																   database:_database]];
		[self _showBrowser];
	}
}

- (IBAction)selectInformalProtocolsTopic:(id)sender
{
	if ([sender isKindOfClass:[NSMenuItem class]]) {
		NSString *frameworkName = [sender menu].title;
		[self selectTopic:[[AKInformalProtocolsTopic alloc] initWithFramework:frameworkName
																	 database:_database]];
		[self _showBrowser];
	}
}

- (IBAction)selectFunctionsTopic:(id)sender
{
	if ([sender isKindOfClass:[NSMenuItem class]]) {
		NSString *frameworkName = [sender menu].title;
		[self selectTopic:[[AKFunctionsTopic alloc] initWithFramework:frameworkName
															 database:_database]];
		[self _showBrowser];
	}
}

- (IBAction)selectGlobalsTopic:(id)sender
{
	if ([sender isKindOfClass:[NSMenuItem class]]) {
		NSString *frameworkName = [sender menu].title;
		[self selectTopic:[[AKGlobalsTopic alloc] initWithFramework:frameworkName
														   database:_database]];
		[self _showBrowser];
	}
}

- (IBAction)selectDocWithDocLocatorRepresentedBy:(id)sender
{
	if ([sender isKindOfClass:[NSMenuItem class]]
		&& [[sender representedObject] isKindOfClass:[AKDocLocator class]]) {

		[self selectDocWithDocLocator:[sender representedObject]];
	}
}

- (IBAction)addTopicToFavorites:(id)sender
{
	AKDocLocator *docLocator = [AKDocLocator withTopic:[self _currentTopic]
										  subtopicName:nil
											   docName:nil];
	[[AKAppDelegate appDelegate] addFavorite:docLocator];
}

#pragma mark - Action methods -- accessing the doc file

- (IBAction)copyDocFileURL:(id)sender
{
	NSURL *docURL = [_docViewController docURL];
	if (docURL) {
		NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
		[pasteboard declareTypes:@[NSStringPboardType] owner:nil];
		[pasteboard setString:docURL.absoluteString forType:NSStringPboardType];
	}
}

- (IBAction)copyDocFilePath:(id)sender
{
	NSURL *docURL = [_docViewController docURL];
	if ([docURL isFileURL]) {
		NSString *docPath = docURL.path;
		NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
		[pasteboard declareTypes:@[NSStringPboardType] owner:nil];
		[pasteboard setString:docPath forType:NSStringPboardType];
	}
}

- (IBAction)openDocFileInBrowser:(id)sender
{
	NSURL *docURL = [_docViewController docURL];
	if (docURL) {
		[[NSWorkspace sharedWorkspace] openURL:docURL];
	}
}

- (IBAction)revealDocFileInFinder:(id)sender
{
	NSURL *docURL = [_docViewController docURL];
	if ([docURL isFileURL]) {
		NSString *docPath = docURL.path;
		if (docPath) {
			NSString *containingDirPath = docPath.stringByDeletingLastPathComponent;
			[[NSWorkspace sharedWorkspace] selectFile:docPath
							 inFileViewerRootedAtPath:containingDirPath];
		}
	}
}

#pragma mark - Action methods -- debugging

- (IBAction)openParseDebugWindow:(id)sender
{
	QLog(@"%s is now a no-op", __PRETTY_FUNCTION__);
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
	NSLog(@"         window -- %@", [self.window ak_bareDescription]);
	NSLog(@"  topic browser -- %@", [_topicBrowserController.topicBrowser ak_bareDescription]);
	NSLog(@"  subtopic list -- %@", [_subtopicListController.subtopicsTable ak_bareDescription]);
	NSLog(@"       doc list -- %@", [_docListController.docListTable ak_bareDescription]);
	NSLog(@"       web view -- %@", [_docViewController.webView ak_bareDescription]);
	NSLog(@"      text view -- %@", [_docViewController.textView ak_bareDescription]);
	NSLog(@"   search field -- %@", [_quicklistController.searchField ak_bareDescription]);
	NSLog(@"      quicklist -- %@", [_quicklistController.quicklistTable ak_bareDescription]);
	NSLog(@"END FUN FACTS about %@\n\n", self);
}

#pragma mark - AKTabChainWindowDelegate methods

- (NSArray *)tabChainViewsForWindow:(NSWindow *)window
{
	NSMutableArray *tabChain = [NSMutableArray array];

	[tabChain addObject:_topicBrowserController.topicBrowser];

	if (NSApp.fullKeyboardAccessEnabled) 	{
		[tabChain addObject:_superclassButton];
		[tabChain addObject:_backButton];
		[tabChain addObject:_forwardButton];
	}

	[tabChain addObject:_subtopicListController.subtopicsTable];
	[tabChain addObject:_docListController.docListTable];
	[tabChain addObject:[_docViewController docView]];

	if (_quicklistDrawer.state == NSDrawerOpenState) 	{
		[self _addDrawerControlsToTabChain:tabChain];
	}

	return tabChain;
}

#pragma mark - AKUIController methods

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
	if (windowLayout == nil) {
		return;
	}

	// Apply the specified window frame.
	[self.window setFrame:windowLayout.windowFrame display:NO];

	// Restore the visibility of the toolbar.
	self.window.toolbar.visible = windowLayout.toolbarIsVisible;

	// Figure out the browser height indicated by windowLayout. If an explicit
	// height is given, use that. Otherwise, if the (now obsolete) fraction is
	// given, use the fraction to calculate the height. Otherwise, use the
	// default height.
	_browserHeightWhenVisible = windowLayout.browserHeight;

	if (_browserHeightWhenVisible <= 0) {
		_browserHeightWhenVisible = [self _heightByTakingFraction:windowLayout.browserFraction
													  ofSplitView:_topLevelSplitView];
		if (_browserHeightWhenVisible <= 0) {
			_browserHeightWhenVisible = _defaultBrowserHeight;
		}
	}

	// Apply the indicated height to the topic browser.
	if ([self _topicBrowserIsVisible]
		&& windowLayout.browserIsVisible) {

		[self _setTopSubviewHeight:_browserHeightWhenVisible
			   forTwoPaneSplitView:_topLevelSplitView
						   animate:NO];
	} else {
		[self _setTopSubviewHeight:0
			   forTwoPaneSplitView:_topLevelSplitView
						   animate:NO];
	}

	// Restore the state of the bottom two thirds.
	[self _setTopSubviewHeight:windowLayout.middleViewHeight
		   forTwoPaneSplitView:_bottomTwoThirdsSplitView
					   animate:NO];

	if (windowLayout.subtopicListWidth) {
		[self _setLeftSubviewWidth:windowLayout.subtopicListWidth
			   forTwoPaneSplitView:_middleThirdSplitView
						   animate:NO];
	}

	[_subtopicListController takeWindowLayoutFrom:windowLayout];
	[_docListController takeWindowLayoutFrom:windowLayout];
	[_docViewController takeWindowLayoutFrom:windowLayout];

	// Restore the state of the Quicklist drawer.
	NSSize drawerContentSize = _quicklistDrawer.contentSize;
	drawerContentSize.width = windowLayout.quicklistDrawerWidth;
	_quicklistDrawer.contentSize = drawerContentSize;

	// Restore the internal state of the Quicklist.
	[_quicklistController takeWindowLayoutFrom:windowLayout];
}

- (void)putWindowLayoutInto:(AKWindowLayout *)windowLayout
{
	if (windowLayout == nil) {
		return;
	}

	// Remember the current window frame.
	windowLayout.windowFrame = self.window.frame;

	// Remember the visibility of the toolbar.
	windowLayout.toolbarIsVisible = self.window.toolbar.visible;

	// Remember the state of the inner split view.
	windowLayout.middleViewHeight = (_middleView.frame.size.height);
	windowLayout.subtopicListWidth = (_subtopicListContainerView.frame.size.width);

	// Remember the state of the topic browser.
	windowLayout.browserIsVisible = [self _topicBrowserIsVisible];
	windowLayout.browserFraction = [self _fractionByComparingHeight:_browserHeightWhenVisible
												toHeightOfSplitView:_topLevelSplitView];
	windowLayout.browserHeight = _browserHeightWhenVisible;
	[_topicBrowserController putWindowLayoutInto:windowLayout];

	// Remember the state of the Quicklist drawer.
	NSInteger state = _quicklistDrawer.state;
	BOOL drawerIsOpen = (state == NSDrawerOpenState) || (state == NSDrawerOpeningState);

	windowLayout.quicklistDrawerIsOpen = drawerIsOpen;
	windowLayout.quicklistDrawerWidth = (_quicklistDrawer.contentSize.width);

	// Remember the internal state of the Quicklist.
	[_quicklistController putWindowLayoutInto:windowLayout];
}

#pragma mark - NSWindowController methods

- (void)windowDidLoad
{
	_defaultBrowserHeight = NSHeight(_topicBrowserContainerView.frame);

	// Load our view controllers and plug their views into the UI. Do this
	// early, because a number of things we do next assume the view controllers
	// have been loaded.
	[self _setUpViewControllers];

	// Add our toolbar.
	//TODO: Is it worth doing this in the nib now that we can?
	[self _setUpToolbar];

	// Apply display preferences specified in the defaults database.
	[self applyUserPreferences];

	// Make the navigation popups use small fonts. I determined empirically that
	// 11 is the size Cocoa uses for small menus.
	NSFont *smallMenuFont = [NSFont menuFontOfSize:11];

	_superclassesMenu.font = smallMenuFont;
	_backMenu.font = smallMenuFont;
	_forwardMenu.font = smallMenuFont;

	// Select NSObject in the topic browser.
	_windowHistoryIndex = -1;
	[_windowHistory removeAllObjects];

	AKClassToken *classToken = [_database classWithName:@"NSObject"];
	[self selectTopic:[[AKClassTopic alloc] initWithClassToken:classToken]];

	// Start with the topic browser having focus.
	[self.window makeFirstResponder:_topicBrowserController.topicBrowser];
}

#pragma mark - NSUserInterfaceValidations methods

- (BOOL)validateUserInterfaceItem:(id)anItem
{
	SEL itemAction = [anItem action];

	if (itemAction == @selector(goBackInHistory:)) {
		return (_windowHistoryIndex > 0);
	} else if (itemAction == @selector(goForwardInHistory:)) {
		return (_windowHistoryIndex < ((int)_windowHistory.count - 1));
	} else if ((itemAction == @selector(goToHistoryItemInBackMenu:))
			   || (itemAction == @selector(goToHistoryItemInForwardMenu:))) {
		return YES;
	} else if (itemAction == @selector(selectSuperclass:)) {
		BOOL isValid = ([[self _currentTopic] parentClassOfTopic] != nil);
		if (isValid && [anItem isKindOfClass:[NSToolbarItem class]]) 	{
			[anItem setToolTip:[self _tooltipForSelectSuperclass]];
		}
		return isValid;
	} else if (itemAction == @selector(selectAncestorClass:)) {
		return ([[self _currentTopic] parentClassOfTopic] != nil);
	} else if ((itemAction == @selector(selectFormalProtocolsTopic:))
			   || (itemAction == @selector(selectInformalProtocolsTopic:))
			   || (itemAction == @selector(selectFunctionsTopic:))
			   || (itemAction == @selector(selectGlobalsTopic:))
			   || (itemAction == @selector(selectDocWithDocLocatorRepresentedBy:))
			   || (itemAction == @selector(rememberWindowLayout:))) {
		return YES;
	} else if (itemAction == @selector(addTopicToFavorites:)) {
		AKTopic *currentTopic = [self _currentTopic];

		// Update the menu item title to reflect what's currently selected in the topic browser.
		if ([anItem isKindOfClass:[NSMenuItem class]]) {
			NSString *topicName = [currentTopic displayName];
			NSString *menuTitle = [NSString stringWithFormat:@"Add \"%@\" to Favorites", topicName];
			[anItem setTitle:menuTitle];
		}

		// Enable the item if the selected topic isn't already a favorite.
		NSArray *favoritesList = [[AKAppDelegate appDelegate] favoritesList];
		AKDocLocator *proposedFavorite = [AKDocLocator withTopic:currentTopic subtopicName:nil docName:nil];

		if ([favoritesList containsObject:proposedFavorite]) {
			return NO;
		} else {
			return YES;
		}
	} else if (itemAction == @selector(toggleQuicklistDrawer:)) {
		if ([anItem isKindOfClass:[NSMenuItem class]]) {
			NSInteger state = _quicklistDrawer.state;

			if ((state == NSDrawerClosedState)
				|| (state == NSDrawerClosingState)) {

				[anItem setTitle:@"Show Quicklist"];
			} else {
				[anItem setTitle:@"Hide Quicklist"];
			}
		}
		return YES;
	} else if (itemAction == @selector(toggleBrowserVisible:)) {
		if ([anItem isKindOfClass:[NSMenuItem class]]) {
			if (![self _topicBrowserIsVisible]
				&& (_browserHeightWhenVisible > 0.0)) {

				[anItem setTitle:@"Show Browser"];
			} else {
				[anItem setTitle:@"Hide Browser"];
			}
		}
		return YES;
	} else if ((itemAction == @selector(copyDocFileURL:))
			   || (itemAction == @selector(copyDocFilePath:))
			   || (itemAction == @selector(openDocFileInBrowser:))
			   || (itemAction == @selector(revealDocFileInFinder:))
			   || (itemAction == @selector(openParseDebugWindow:))) {
		return ([self currentDocLocator] != nil);
	} else {
		return NO;
	}
}

#pragma mark - NSSplitView delegate methods

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
	// As it happens, we want the first subview of all our split views to stay
	// fixed-sized.
	return (subview != splitView.subviews[0]);
}

#pragma mark - NSWindow delegate methods

//FIXME: This is a workaround to either a bug or something I don't
// understand; when the prefs panel is dismissed, the AppKiDo window below
// it doesn't come front (despite becoming key) if there was an intervening
// window from another app; weird because if change the prefs panel to an
// NSWindow, it works as expected; anyway, this kludge forces the window
// front when it becomes key
- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
	[(NSWindow *)aNotification.object orderFront:nil];
}

//TODO: Not sure why this is here.  The app delegate listens for
// NSWindowWillCloseNotification and removes the window controller from its
// array of window controllers.  No need to do that *and* implement
// windowWillClose: -- right?
//
//// "If you want the closing of a window to make both window and window controller go away when it isn’t part of a document, your subclass of NSWindowController can observe the NSWindowWillCloseNotification notification or, as the window delegate, implement the windowWillClose: method."
//// http://developer.apple.com/library/Mac/documentation/Cocoa/Conceptual/WinPanel/Concepts/UsingWindowController.html
//- (void)windowWillClose:(NSNotification *)aNotification
//{
//    [self autorelease];
//}

#pragma mark - Private methods

- (void)_setUpViewControllers
{
	// Populate our various container views.
	_topicBrowserController = [self _vcWithClass:[AKTopicBrowserViewController class]
										 nibName:@"TopicBrowserView"
								   containerView:_topicBrowserContainerView];
	_subtopicListController = [self _vcWithClass:[AKSubtopicListViewController class]
										 nibName:@"SubtopicListView"
								   containerView:_subtopicListContainerView];
	_docListController = [self _vcWithClass:[AKDocListViewController class]
									nibName:@"DocListView"
							  containerView:_docListContainerView];
	_docViewController = [self _vcWithClass:[AKDocViewController class]
									nibName:@"DocView"
							  containerView:_docContainerView];
	_quicklistController = [self _vcWithClass:[AKQuicklistViewController class]
									  nibName:@"QuicklistView"
								containerView:_quicklistDrawer.contentView];

	// Load the window with initial data.
	AKBrowser *topicBrowser = _topicBrowserController.topicBrowser;

	[topicBrowser loadColumnZero];
	self.window.initialFirstResponder = topicBrowser;
	(void)[self.window makeFirstResponder:topicBrowser];
}

- (void)_setUpToolbar
{
	NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:_AKToolbarID];

	// Set up toolbar properties.
	[toolbar setAllowsUserCustomization:YES];
	[toolbar setAutosavesConfiguration:YES];
	toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;

	// We are the delegate.
	toolbar.delegate = self;

	// Attach the toolbar to the browser window.
	self.window.toolbar = toolbar;
}

- (id)_vcWithClass:(Class)vcClass nibName:(NSString *)nibName containerView:(NSView *)containerView
{
	id vc = [[vcClass alloc] initWithNibName:nibName windowController:self];

	// Stuff the view controller's view into the container view.
	[vc view].frame = containerView.bounds;
	[vc view].autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);

	[containerView addSubview:[vc view]];

	// Patch the view controller into the responder chain after self.
	//TODO: Do I need to unpatch on dealloc?  Do I even need to patch at all any more, now that VC's are patched in by AppKit?
	NSResponder *nextResponder = self.nextResponder;
	self.nextResponder = vc;
	[vc setNextResponder:nextResponder];

	return vc;
}

- (NSString *)_tooltipForSelectSuperclass
{
	return [NSString stringWithFormat:(@"Go to superclass (%@)"
									   @"\n(Control-click or right-click for menu)"),
			[[self _currentTopic] parentClassOfTopic].name];
}

- (void)_refreshNavigationButtons
{
	[self _refreshBackButton];
	[self _refreshForwardButton];
	[self _refreshSuperclassButton];
}

- (void)_refreshSuperclassButton
{
	AKClassToken *parentClass = [[self _currentTopic] parentClassOfTopic];

	// Enable or disable the Superclass button as appropriate.
	_superclassButton.enabled = (parentClass != nil);
	if (_superclassButton.enabled) {
		_superclassButton.toolTip = [self _tooltipForSelectSuperclass];
	}

	// Empty the Superclass button's contextual menu.
	while (_superclassesMenu.numberOfItems > 0) {
		[_superclassesMenu removeItemAtIndex:0];
	}

	// Reconstruct the Superclass button's contextual menu.
	AKClassToken *ancestorItem = parentClass;
	while (ancestorItem != nil) {
		[_superclassesMenu addItemWithTitle:ancestorItem.name
									 action:@selector(selectAncestorClass:)
							  keyEquivalent:@""];
		ancestorItem = ancestorItem.parentClass;
	}
}

- (void)_refreshBackButton
{
	NSInteger i;

	// Enable or disable the Back button as appropriate.
	_backButton.enabled = (_windowHistoryIndex > 0);

	// Empty the Back button's contextual menu.
	while (_backMenu.numberOfItems > 0) {
		[_backMenu removeItemAtIndex:0];
	}

	// Reconstruct the Back button's contextual menu.
	for (i = _windowHistoryIndex - 1; i >= 0; i--) {
		AKDocLocator *historyItem = _windowHistory[i];
		NSString *menuItemName = [historyItem displayName];
		if (menuItemName) {
			[_backMenu addItemWithTitle:menuItemName
								 action:@selector(goToHistoryItemInBackMenu:)
						  keyEquivalent:@""];
		}
	}
}

- (void)_refreshForwardButton
{
	NSInteger historySize = (int)_windowHistory.count;
	NSInteger i;

	// Enable or disable the Forward button as appropriate.
	_forwardButton.enabled = (_windowHistoryIndex < historySize - 1);

	// Empty the Forward button's contextual menu.
	while (_forwardMenu.numberOfItems > 0) {
		[_forwardMenu removeItemAtIndex:0];
	}

	// Reconstruct the Forward button's contextual menu.
	for (i = _windowHistoryIndex + 1; i < historySize; i++) {
		AKDocLocator *historyItem = _windowHistory[i];
		NSString *menuItemName = [historyItem displayName];
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
	if (topic == nil) {
		DIGSLogInfo(@"can't navigate to a nil topic");
		return;
	}

	AKDocLocator *newHistoryItem = [AKDocLocator withTopic:topic
											  subtopicName:subtopicName
												   docName:docName];

	[_topicBrowserController goFromDocLocator:[self currentDocLocator] toDocLocator:newHistoryItem];
	[_subtopicListController goFromDocLocator:[self currentDocLocator] toDocLocator:newHistoryItem];

	_docListController.subtopic = [_subtopicListController selectedSubtopic];
	[_docListController goFromDocLocator:[self currentDocLocator] toDocLocator:newHistoryItem];

	[_docViewController goFromDocLocator:[self currentDocLocator] toDocLocator:newHistoryItem];

	_topicDescriptionField.stringValue = [topic stringToDisplayInDescriptionField];
	_docCommentField.stringValue = [_docListController docComment];

	if (shouldAddToHistory) {
		[self _addHistoryItem:newHistoryItem];
	}
}

// All the history navigation methods come through here.
- (void)_goToHistoryItemAtIndex:(NSInteger)historyIndex
{
	if ((historyIndex < 0) || (historyIndex >= (NSInteger)_windowHistory.count)) {
		return;
	}

	// Navigate to the specified history item.
	AKDocLocator *historyItem = _windowHistory[historyIndex];

	[self _selectTopic:historyItem.topicToDisplay
		  subtopicName:historyItem.subtopicName
			   docName:historyItem.docName
		  addToHistory:NO];

	// Update our marker index into the history array.
	_windowHistoryIndex = historyIndex;
	DIGSLogDebug(@"jumped to history index %ld, history count=%ld",
				 (long)_windowHistoryIndex, (long)[_windowHistory count]);

	// Update miscellaneous parts of the UI that reflect our current
	// position in history.
	[self _refreshNavigationButtons];
	self.window.title = [historyItem displayName];
}

- (void)_addHistoryItem:(AKDocLocator *)newHistoryItem
{
	AKDocLocator *currentHistoryItem = [self currentDocLocator];
	NSInteger maxHistory = [AKPrefUtils intValueForPref:AKMaxHistoryPrefName];

	if ([currentHistoryItem isEqual:newHistoryItem]) {
		return;
	}

	// Trim history beyond our max memory.
	while ((int)_windowHistory.count > maxHistory - 1) {
		[_windowHistory removeObjectAtIndex:0];
		if (_windowHistoryIndex >= 0) {
			_windowHistoryIndex--;
		}
	}

	// Trim history items ahead of where the current one is.
	// Remember -count returns an *unsigned* int!
	if (_windowHistoryIndex >= 0) {
		while ((int)_windowHistory.count > _windowHistoryIndex + 1) {
			[_windowHistory removeLastObject];
		}
	}

	// Add the current navigation state to the navigation history.
	[_windowHistory addObject:newHistoryItem];
	_windowHistoryIndex = _windowHistory.count - 1;
	DIGSLogDebug(@"added history item [%@][%@][%@] at index %ld",
				 [[newHistoryItem topicToDisplay] pathInTopicBrowser],
				 [newHistoryItem subtopicName],
				 [newHistoryItem docName],
				 (long)_windowHistoryIndex);

	// Any time the history changes, we want to do the following UI updates.
	[self _refreshNavigationButtons];
	self.window.title = [newHistoryItem displayName];
}

- (AKTopic *)_currentTopic
{
	return [self currentDocLocator].topicToDisplay;
}

- (void)_showBrowser
{
	if (![self _topicBrowserIsVisible]) {
		[self toggleBrowserVisible:nil];
	}
}

- (BOOL)_topicBrowserIsVisible
{
	return (_topicBrowserContainerView.frame.size.height > 0);
}

// Assumes the split view has two subviews, one above the other.
- (void)_setTopSubviewHeight:(CGFloat)newHeight
		 forTwoPaneSplitView:(NSSplitView *)splitView
					 animate:(BOOL)shouldAnimate
{
	NSView *viewOne = splitView.subviews[0];
	NSRect frameOne = viewOne.frame;
	NSView *viewTwo = splitView.subviews[1];
	NSRect frameTwo = viewTwo.frame;

	frameOne.size.height = newHeight;
	frameTwo.size.height = (splitView.bounds.size.height
							- splitView.dividerThickness
							- newHeight);
	if (shouldAnimate) {
		[NSAnimationContext beginGrouping];
		[NSAnimationContext currentContext].duration = 0.1;
		{{
			[viewOne animator].frame = frameOne;
			[viewTwo animator].frame = frameTwo;
		}}
		[NSAnimationContext endGrouping];
	} else {
		viewOne.frame = frameOne;
		viewTwo.frame = frameTwo;
	}
}

// Assumes the split view has two subviews, side by side.
- (void)_setLeftSubviewWidth:(CGFloat)newWidth
		 forTwoPaneSplitView:(NSSplitView *)splitView
					 animate:(BOOL)shouldAnimate
{
	NSView *viewOne = splitView.subviews[0];
	NSRect frameOne = viewOne.frame;
	NSView *viewTwo = splitView.subviews[1];
	NSRect frameTwo = viewTwo.frame;

	frameOne.size.width = newWidth;
	frameTwo.size.width = (splitView.bounds.size.width
						   - splitView.dividerThickness
						   - newWidth);
	if (shouldAnimate) {
		[NSAnimationContext beginGrouping];
		[NSAnimationContext currentContext].duration = 0.1;
		{{
			[viewOne animator].frame = frameOne;
			[viewTwo animator].frame = frameTwo;
		}}
		[NSAnimationContext endGrouping];
	} else {
		viewOne.frame = frameOne;
		viewTwo.frame = frameTwo;
	}
}

- (CGFloat)_fractionByComparingHeight:(CGFloat)height toHeightOfSplitView:(NSSplitView *)splitView
{
	NSInteger numberOfDividers = splitView.subviews.count - 1;
	CGFloat totalHeightOfSubviews = (splitView.frame.size.height
									 - numberOfDividers*splitView.dividerThickness);
	return height / totalHeightOfSubviews;
}

- (CGFloat)_heightByTakingFraction:(CGFloat)fraction ofSplitView:(NSSplitView *)splitView
{
	NSInteger numberOfDividers = splitView.subviews.count - 1;
	CGFloat totalHeightOfSubviews = (splitView.frame.size.height
									 - numberOfDividers*splitView.dividerThickness);
	return round(fraction * totalHeightOfSubviews);
}

- (void)_addDrawerControlsToTabChain:(NSMutableArray *)tabChain
{
	if (NSApp.fullKeyboardAccessEnabled) {
		[tabChain addObject:_quicklistController.quicklistRadio1];
		[tabChain addObject:_quicklistController.quicklistRadio2];
		[tabChain addObject:_quicklistController.frameworkPopup];
		[tabChain addObject:_quicklistController.quicklistRadio3];
	}
	
	[tabChain addObject:_quicklistController.searchField];
	
	if (NSApp.fullKeyboardAccessEnabled) {
		[tabChain addObject:_quicklistController.searchOptionsPopup];
	}
	
	[tabChain addObject:_quicklistController.quicklistTable];
	
	if (NSApp.fullKeyboardAccessEnabled) {
		[tabChain addObject:_quicklistController.removeFavoriteButton];
	}
}

@end
