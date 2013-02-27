/*
 * AKBrowserWindowController.h
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import "AKUIController.h"

@class AKDatabase;
@class AKDoc;
@class AKDocListViewController;
@class AKDocLocator;
@class AKDocViewController;
@class AKQuicklistViewController;
@class AKSavedWindowState;
@class AKTopic;
@class AKSubtopicListViewController;
@class AKTopicBrowserViewController;
@class AKWindowLayout;

// Naming convention:
// "jumpTo" methods are all here; "jumpTo" means "navigate to and add to
// history"; "navigate" means "navigate the various subcontrollers to";
// navigation always starts here at the window controller and propagates
// to subcontrollers

/*!
 * Manages an AppKiDo browser window. Coordinates view controllers for the views
 * in the window. Manages the window's navigation history.
 *
 * Patches the view controllers after self in the responder chain so they can
 * pick up action messages even when not in the first responder's responder
 * chain. The vc's are such that this shouldnt' cause a conflict between action
 * messages with the same name.
 */
@interface AKWindowController : NSWindowController <AKUIController, NSToolbarDelegate>
{
@private
    // The source of all data the window displays.
    AKDatabase *_database;

    // The window's navigation history. Elements are AKDocLocators. The last
    // element is the most recent.
    NSMutableArray *_windowHistory;

    // The index within _windowHistory of our current navigation state.
    NSInteger _windowHistoryIndex;

    // Remembered for when we hide/show the browser.  We remember it as a
    // fraction instead of an absolute height because the user can toggle
    // the browser off, resize the window, and toggle the browser back on.
    CGFloat _browserFractionWhenVisible;
    
    // View controllers that manage different portions of the window.
    AKTopicBrowserViewController *_topicBrowserController;
    AKSubtopicListViewController *_subtopicListController;
    AKDocListViewController *_docListController;
    AKDocViewController *_docContainerViewController;
    AKQuicklistViewController *_quicklistController;

    // Drawer where we put the Quicklist view.

    // IBOutlets.
    NSSplitView *_topLevelSplitView;
    NSSplitView *_innerSplitView;
    NSView *_middleView;

    NSView *_topicBrowserContainerView;
    NSView *_subtopicListContainerView;
    NSView *_docListContainerView;
    NSView *_docContainerView;
    
    NSTextField *_topicDescriptionField;
    NSTextField *_docCommentField;

    NSButton *_backButton;
    NSButton *_forwardButton;
    NSButton *_superclassButton;

    NSMenu *_backMenu;
    NSMenu *_forwardMenu;
    NSMenu *_superclassesMenu;

    NSDrawer *_quicklistDrawer;
}

@property (nonatomic, assign) IBOutlet NSSplitView *topLevelSplitView;
@property (nonatomic, assign) IBOutlet NSSplitView *innerSplitView;
@property (nonatomic, assign) IBOutlet NSView *middleView;

@property (nonatomic, assign) IBOutlet NSView *topicBrowserContainerView;
@property (nonatomic, assign) IBOutlet NSView *subtopicListContainerView;
@property (nonatomic, assign) IBOutlet NSView *docListContainerView;
@property (nonatomic, assign) IBOutlet NSView *docContainerView;

@property (nonatomic, assign) IBOutlet NSTextField *topicDescriptionField;
@property (nonatomic, assign) IBOutlet NSTextField *docCommentField;

@property (nonatomic, assign) IBOutlet NSButton *backButton;
@property (nonatomic, assign) IBOutlet NSButton *forwardButton;
@property (nonatomic, assign) IBOutlet NSButton *superclassButton;

@property (nonatomic, assign) IBOutlet NSMenu *backMenu;
@property (nonatomic, assign) IBOutlet NSMenu *forwardMenu;
@property (nonatomic, assign) IBOutlet NSMenu *superclassesMenu;

@property (nonatomic, assign) IBOutlet NSDrawer *quicklistDrawer;

#pragma mark -
#pragma mark Init/dealloc/awake

/*! Designated initializer. */
- (id)initWithDatabase:(AKDatabase *)database;

#pragma mark -
#pragma mark Getters and setters

- (AKDatabase *)database;

- (AKDocLocator *)currentHistoryItem;

/*!
 * Returns the currently displayed doc. If there is no current doc, looks for a
 * General/Overview doc on the assumption that the current topic is probably a class.
 * For example, when NSFileWrapper > "Class Methods" is selected, there is no doc in
 * the doc view, because NSFileWrapper has no class methods, but it is useful to
 * return the file containing the NSFileWrapper docs. (Thanks to Gerriet for pointing
 * out this case and providing code to look for General/Overview.)
 *
 * If all else fails, returns nil.
 */
- (AKDoc *)currentDoc;

/*! Returns the path to the file containing [self currentDoc], or nil. */
- (NSString *)currentDocPath;

/*! Returns the URL for [self currentDocPath], or nil. */
- (NSURL *)currentDocURL;

#pragma mark -
#pragma mark Navigation

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

/*! All the other "jumpTo" methods come through here. */
- (void)jumpToTopic:(AKTopic *)obj
       subtopicName:(NSString *)subtopicName
            docName:(NSString *)docName;

/*!
 * Returns YES if we are able to jump to the URL, either within the app if
 * possible or, if necessary, in the user's browser.
 */
- (BOOL)jumpToLinkURL:(NSURL *)linkURL;

- (void)bringToFront;

- (void)searchForString:(NSString *)aString;

- (void)putSavedWindowStateInto:(AKSavedWindowState *)savedWindowState;

#pragma mark -
#pragma mark Action methods -- window layout

- (IBAction)rememberWindowLayout:(id)sender;

//- (IBAction)addBrowserColumn:(id)sender;

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

/*! Adds the currently selected topic to the Favorites quicklist. */
- (IBAction)addTopicToFavorites:(id)sender;

- (IBAction)findNext:(id)sender;

- (IBAction)findPrevious:(id)sender;

- (IBAction)revealDocFileInFinder:(id)sender;

- (IBAction)copyDocTextURL:(id)sender;

- (IBAction)openDocURLInBrowser:(id)sender;

@end
