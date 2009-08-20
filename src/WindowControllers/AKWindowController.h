/*
 * AKWindowController.h
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class AKDatabase;
@class AKTopic;
@class AKDocLocator;
@class AKDocLocator;
@class AKTopicBrowserController;
@class AKDocListController;
@class AKQuicklistController;
@class AKWindowLayout;
@class AKSavedWindowState;
@class AKDocView;

/*!
 * @class       AKWindowController
 * @abstract    Controller for AppKiDo browser windows.
 * @discussion  Each browser window has a AKWindowController as its
 *              delegate.  An AKWindowController coordinates subcontroller
 *              objects that manage various subviews.  It also manages its
 *              window's navigation history.
 *
 *              The information displayed in a browser window has a
 *              hierarchical structure.  At any given time, a "topic"
 *              (also called the "main topic") is selected in the window.
 *              This is the object selected in the topic browser.  Details
 *              about the topic are displayed in the "subtopics" list, the
 *              doc list, and the doc text view.
 */
// "jumpTo" methods are all here; "jumpTo" means "navigate to and add to
// history"; "navigate" means "navigate the various subcontrollers to";
// navigation always starts here at the window controller and propagates
// to subcontrollers
@interface AKWindowController : NSObject
{
    AKDatabase *_database;

    // The window's navigation history.  Elements are AKDocLocators.
    // Elements are added to the end.
    NSMutableArray *_windowHistory;

    // The index within _windowHistory of our current navigation state.
    int _windowHistoryIndex;

    // Remembered for when we hide/show the browser.  We remember it as a
    // fraction instead of an absolute height because the user can toggle
    // the browser off, resize the window, and toggle the browser back on.
    float _browserFractionWhenVisible;

    // Outlets to subcontrollers that manage different portions of the
    // window.
    IBOutlet AKTopicBrowserController *_topicBrowserController;
    IBOutlet AKDocListController *_docListController;
    IBOutlet AKQuicklistController *_quicklistController;

    // UI outlets -- navigation buttons.
    IBOutlet NSButton *_backButton;
    IBOutlet NSButton *_forwardButton;
    IBOutlet NSButton *_superclassButton;

    // UI outlets -- top-level view that fills the window.
    IBOutlet NSSplitView *_topLevelSplitView;

    // UI outlets -- the splitview containing the two bottom sections.
    IBOutlet NSSplitView *_innerSplitView;
    IBOutlet NSView *_middleView;

    // UI outlets -- the topic browser.
    IBOutlet NSBrowser *_topicBrowser;

    // UI outlets -- bottom pane, showing the doc text.
    IBOutlet AKDocView *_docView;

    // UI outlets -- contextual menus.
    IBOutlet NSMenu *_docTextMenu;
    IBOutlet NSMenu *_backMenu;
    IBOutlet NSMenu *_forwardMenu;
    IBOutlet NSMenu *_superclassesMenu;

    // UI outlets -- the Quicklist drawer.  This is connected to
    // _quicklistController.
    IBOutlet NSDrawer *_quicklistDrawer;
}


#pragma mark -
#pragma mark Init/awake/dealloc

/*! Designated initializer. */
- (id)initWithDatabase:(AKDatabase *)database;


#pragma mark -
#pragma mark Getters and setters

- (AKDatabase *)database;

- (NSWindow *)window;


#pragma mark -
#pragma mark User preferences

/*!
 * @method      applyUserPreferences
 * @discussion  Tells my subordinate controller objects to apply the user
 *   preference settings.
 */
- (void)applyUserPreferences;


#pragma mark -
#pragma mark Navigation

- (AKDocLocator *)currentHistoryItem;

/*!
 * @method      openWindowWithQuicklistDrawer:
 * @discussion  Called to display the window just after it has been
 *   initialized.  The first time we display the window is special, because
 *   if we have to open the Search drawer, we have to do so after the window
 *   is displayed.
 */
- (void)openWindowWithQuicklistDrawer:(BOOL)drawerIsOpen;

- (void)jumpToTopic:(AKTopic *)obj;

- (void)jumpToSubtopicWithName:(NSString *)subtopicName;

- (void)jumpToDocName:(NSString *)docName;

- (void)jumpToDocLocator:(AKDocLocator *)docLocator;

// all the other "jumpTo" methods come through here
- (void)jumpToTopic:(AKTopic *)obj
    subtopicName:(NSString *)subtopicName
    docName:(NSString *)docName;

// linkObj must be either an NSURL or a string containing an absolute URL.
// Returns YES if we are able to jump to the URL, either within the app if
// possible or, if necessary, via NSWorkspace.
- (BOOL)jumpToLinkURL:(NSURL *)linkURL;

/*!
 * @method      focusOnDocView
 * @discussion  Tries to give first responder status to the doc text view.
 *              Returns that view if successful.
 */
- (NSView *)focusOnDocView;

- (void)focusOnDocListTable;

- (void)bringToFront;

- (void)searchForString:(NSString *)aString;


#pragma mark -
#pragma mark Window layout

- (void)takeWindowLayoutFrom:(AKWindowLayout *)windowLayout;

- (void)putWindowLayoutInto:(AKWindowLayout *)windowLayout;

- (void)putSavedWindowStateInto:(AKSavedWindowState *)savedWindowState;


#pragma mark -
#pragma mark UI item validation

/*!
 * @method      validateItem:
 * @discussion  Returns true if the specified UI item should be enabled.
 *              Contains shared logic for validating both menu items and
 *              toolbar items.
 * @param       anItem  Either an NSMenuItem or an NSToolbarItem
 */
- (BOOL)validateItem:(id)anItem;


#pragma mark -
#pragma mark Action methods -- window layout

- (IBAction)rememberWindowLayout:(id)sender;

- (IBAction)addBrowserColumn:(id)sender;

- (IBAction)removeBrowserColumn:(id)sender;

- (IBAction)toggleBrowserVisible:(id)sender;

- (IBAction)showBrowser:(id)sender;

- (IBAction)toggleQuicklistDrawer:(id)sender;


#pragma mark -
#pragma mark Action methods -- navigation

- (IBAction)navigateBack:(id)sender;

- (IBAction)navigateForward:(id)sender;

- (IBAction)doBackMenuAction:(id)sender;

- (IBAction)doForwardMenuAction:(id)sender;

- (IBAction)jumpToSuperclass:(id)sender;

- (IBAction)jumpToFrameworkFormalProtocols:(id)sender;

- (IBAction)jumpToFrameworkInformalProtocols:(id)sender;

- (IBAction)jumpToFrameworkFunctions:(id)sender;

- (IBAction)jumpToFrameworkGlobals:(id)sender;

/*!
 * @method      jumpToDocLocatorRepresentedBy:
 * @discussion  Used by items in the Favorites menu.
 * @param       sender  Should either respond to -representedObject by
 *              returning an AKDocLocator, or respond to -selectedCell
 *              with a cell whose -representedObject is an AKDocLocator.
 */
- (IBAction)jumpToDocLocatorRepresentedBy:(id)sender;

/*!
 * @method      addTopicToFavorites:
 * @discussion  Action method that adds the currently selected topic
 *              to the Favorites quicklist.
 */
- (IBAction)addTopicToFavorites:(id)sender;

- (IBAction)findNext:(id)sender;

- (IBAction)findPrevious:(id)sender;

- (IBAction)revealDocFileInFinder:(id)sender;

- (IBAction)copyDocTextURL:(id)sender;

- (IBAction)openDocURLInBrowser:(id)sender;


#pragma mark -
#pragma mark Action methods -- search (forwarded to the quicklist controller)

- (IBAction)selectSearchField:(id)sender;

- (IBAction)selectPreviousSearchResult:(id)sender;

- (IBAction)selectNextSearchResult:(id)sender;

@end
