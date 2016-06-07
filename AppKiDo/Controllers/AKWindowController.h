/*
 * AKWindowController.h
 *
 * Created by Andy Lee on Wed Jul 03 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import "AKUIConfigurable.h"

@class AKDatabase;
@class AKDocListViewController;
@class AKDocLocator;
@class AKDocViewController;
@class AKQuicklistViewController;
@class AKSavedWindowState;
@class AKTopic;
@class AKSubtopicListViewController;
@class AKTopicBrowserViewController;
@class AKWindowLayout;

/*!
 * Manages an AppKiDo browser window. Coordinates view controllers for the views
 * in the window. Manages the window's navigation history.
 *
 * Patches the view controllers after self in the responder chain so they can
 * pick up action messages even when not in the first responder's responder
 * chain. The action methods of the view controllers are such that this
 * shouldn't cause a conflict between action messages with the same name.
 */
@interface AKWindowController : NSWindowController <AKUIConfigurable, NSToolbarDelegate, NSUserInterfaceValidations, NSSplitViewDelegate, NSWindowDelegate>
{
@private
	// The source of all data the window displays.
	AKDatabase *_database;

	// The window's navigation history. Elements are AKDocLocators. The last
	// element is the most recent.
	NSMutableArray *_windowHistory;

	// The index within _windowHistory of our current navigation state.
	NSInteger _windowHistoryIndex;

	// The height of the topic browser when it's not collapsed. Used when the
	// browser's visibility is toggled.
	CGFloat _browserHeightWhenVisible;

	// Default browser height to use when we have neither an explicit height nor
	// a fraction.
	CGFloat _defaultBrowserHeight;

	// View controllers that manage different portions of the window.
	AKTopicBrowserViewController *_topicBrowserController;
	AKSubtopicListViewController *_subtopicListController;
	AKDocListViewController *_docListController;
	AKDocViewController *_docViewController;
	AKQuicklistViewController *_quicklistController;
}

@property (readonly, strong) AKDatabase *database;

@property (readonly, strong) AKDocLocator *currentDocLocator;

// These container views will have views stuffed inside them. Those views will
// be loaded by various view controllers.
@property (nonatomic, weak) IBOutlet NSView *topicBrowserContainerView;
@property (nonatomic, weak) IBOutlet NSView *subtopicListContainerView;
@property (nonatomic, weak) IBOutlet NSView *docListContainerView;
@property (nonatomic, weak) IBOutlet NSView *docContainerView;

/*! Top pane contains the topic browser, bottom pane contains bottomTwoThirdsSplitView. */
@property (nonatomic, weak) IBOutlet NSSplitView *topLevelSplitView;

/*! Top pane contains the "middle third", bottom pane contains the doc view. */
@property (nonatomic, weak) IBOutlet NSSplitView *bottomTwoThirdsSplitView;

/*! Contains topicDescriptionField and middleThirdSplitView. */
@property (nonatomic, weak) IBOutlet NSView *middleView;

/*! The "middle third" contains the subtopic list and doc list, side by side. */
@property (nonatomic, weak) IBOutlet NSSplitView *middleThirdSplitView;

@property (readonly, strong) NSView *docView;

// These things are in the "middle third".
@property (nonatomic, weak) IBOutlet NSTextField *topicDescriptionField;
@property (nonatomic, weak) IBOutlet NSButton *backButton;
@property (nonatomic, weak) IBOutlet NSButton *forwardButton;
@property (nonatomic, weak) IBOutlet NSButton *superclassButton;
@property (nonatomic, weak) IBOutlet NSMenu *backMenu;
@property (nonatomic, weak) IBOutlet NSMenu *forwardMenu;
@property (nonatomic, weak) IBOutlet NSMenu *superclassesMenu;

/*! At the bottom of the window. May display info about the selected doc. */
@property (nonatomic, weak) IBOutlet NSTextField *docCommentField;
@property (nonatomic, weak) IBOutlet NSTextField *docSetInfoField;

/*! On the left side of the window. */
@property (nonatomic, weak) IBOutlet NSDrawer *quicklistDrawer;

#pragma mark - Init/dealloc/awake

/*! Designated initializer though not marked as such.  Too much hassle avoiding compiler warnings in this case. */
- (instancetype)initWithDatabase:(AKDatabase *)database /*NS_DESIGNATED_INITIALIZER*/;

#pragma mark - Navigation

/*! Selects the topic in the topic browser. Updates the rest of the window. */
- (void)selectTopic:(AKTopic *)obj;

/*! Tries to select the specified subtopic within the selected topic. */
- (void)selectSubtopicWithName:(NSString *)subtopicName;

/*! Tries to select the specified doc within the selected subtopic. */
- (void)selectDocWithName:(NSString *)docName;

- (void)selectDocWithDocLocator:(AKDocLocator *)docLocator;

/*!
 * Returns YES if we are able to jump to the URL, either within the app if
 * possible or, if necessary, in the user's browser.
 */
- (BOOL)followLinkURL:(NSURL *)linkURL;

- (void)openQuicklistDrawer;

- (void)searchForString:(NSString *)aString;

- (void)putSavedWindowStateInto:(AKSavedWindowState *)savedWindowState;

- (void)revealPopQuizSymbol:(NSString *)apiSymbol;

#pragma mark - Action methods -- window layout

- (IBAction)rememberWindowLayout:(id)sender;

- (IBAction)toggleBrowserVisible:(id)sender;

- (IBAction)toggleQuicklistDrawer:(id)sender;

#pragma mark - Action methods -- navigation

- (IBAction)goBackInHistory:(id)sender;

- (IBAction)goForwardInHistory:(id)sender;

/*! Expects sender to be an NSMenuItem in the Back popup menu. */
- (IBAction)goToHistoryItemInBackMenu:(id)sender;

/*! Expects sender to be an NSMenuItem in the Forward popup menu. */
- (IBAction)goToHistoryItemInForwardMenu:(id)sender;

- (IBAction)selectSuperclass:(id)sender;

/*! Expects sender to be an NSMenuItem in the Superclasses popup menu. */
- (IBAction)selectAncestorClass:(id)sender;

/*!
 * Used by items in the Favorites menu. Does nothing unless sender is an
 * NSMenuItem whose representedObject is an AKDocLocator.
 */
- (IBAction)selectDocWithDocLocatorRepresentedBy:(id)sender;

/*! Adds the currently selected topic to the Favorites quicklist. */
- (IBAction)addTopicToFavorites:(id)sender;

#pragma mark - Action methods -- accessing the doc file

- (IBAction)copyDocFileURL:(id)sender;

- (IBAction)copyDocFilePath:(id)sender;

- (IBAction)openDocFileInBrowser:(id)sender;

- (IBAction)revealDocFileInFinder:(id)sender;

#pragma mark - Action methods -- debugging

- (IBAction)printFunFacts:(id)sender;

@end
