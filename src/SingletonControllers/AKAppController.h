/*
 * AKAppController.h
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class AKAboutWindowController;
@class AKDatabase;
@class AKDocLocator;
@class AKWindowController;
@class AKPrefPanelController;

/*!
 * @class       AKAppController
 * @abstract    Application-level controller object.
 * @discussion  AppKiDo's application delegate.  Has subordinate controllers:
 *              one for the Prefs panel, one for the Quicklist panel, and one
 *              for each browser window.
 *
 *              On launch, displays the splash window, loads the database,
 *              and loads window states that were remembered from the
 *              previous launch.  On quit, saves the states of all open
 *              windows.
 */
@interface AKAppController : NSObject
{
    AKDatabase *_appDatabase;

    BOOL _finishedInitializing;  // Becomes true when -awakeFromNib finishes.
    AKPrefPanelController *_prefPanelController;  // Lazily instantiated.
    AKAboutWindowController *_aboutWindowController;  // Lazily instantiated.

    // Elements are AKWindowControllers.
    NSMutableArray *_windowControllers;

    // Elements are AKDocLocators.
    NSMutableArray *_favoritesList;

    // IB outlets.
    IBOutlet NSWindow *_splashWindow;
    IBOutlet NSTextField *_splashVersionField;
    IBOutlet NSTextField *_splashMessageField;
    IBOutlet NSTextField *_splashMessage2Field;

    IBOutlet NSMenuItem *_firstGoMenuDivider;
}


#pragma mark -
#pragma mark Factory methods

+ (id)sharedInstance;


#pragma mark -
#pragma mark Getters and setters

- (AKDatabase *)appDatabase;


#pragma mark -
#pragma mark Navigation

/*!
 * @method      selectedTextView
 * @discussion  If a text view has keyboard focus, returns that text view.
 */
- (NSTextView *)selectedTextView;

/*!
 * @method      frontmostWindowController
 * @discussion  Search the window list for the topmost browser window.
 *              Returns that window's window controller, or nil.
 */
- (AKWindowController *)frontmostWindowController;

/*!
 * @method      openNewWindow
 * @discussion  Opens a new browser window.  Returns the newly created
 *              window controller.
 */
- (AKWindowController *)controllerForNewWindow;


#pragma mark -
#pragma mark Preferences

/*!
 * @method      applyUserPreferences
 * @discussion  Tells my subordinate controller objects to apply the
 *              user's preference settings to the things they control.
 */
- (void)applyUserPreferences;


#pragma mark -
#pragma mark External search requests

- (void)searchForString:(NSString *)searchString;


#pragma mark -
#pragma mark AppleScript support

- (id)handleSearchScriptCommand:(NSScriptCommand *)aCommand;


#pragma mark -
#pragma mark Managing the user's Favorites list

/*!
 * @method      favoritesList
 * @discussion  Returns an array of AKDocLocators for the items in the
 *              user's Favorites list.
 */
- (NSArray *)favoritesList;

- (void)addFavorite:(AKDocLocator *)docLocator;

- (void)removeFavoriteAtIndex:(NSInteger)favoritesIndex;

- (void)moveFavoriteFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;


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
#pragma mark Action methods

/*!
 * @method      openAboutPanel:
 * @discussion  Action method that displays the About panel.
 */
- (IBAction)openAboutPanel:(id)sender;

/*!
 * @method      checkForNewerVersion:
 * @discussion  Action method that checks whether a newer version of
 *              the app is available.
 */
- (IBAction)checkForNewerVersion:(id)sender;

/*!
 * @method      openPrefsPanel:
 * @discussion  Action method that tells my AKPrefPanelController to open
 *              the preferences panel.
 */
- (IBAction)openPrefsPanel:(id)sender;

/*!
 * @method      openNewWindow:
 * @discussion  Action method that opens a new browser window.
 */
- (IBAction)openNewWindow:(id)sender;

/*!
 * @method      scrollToTextSelection:
 * @discussion  Action method that tells me to scroll the currently
 *              first-responding text view, if there is one, to show
 *              the text that is selected in the view.
 */
- (IBAction)scrollToTextSelection:(id)sender;

/*!
 * @method      exportDatabase:
 * @discussion  Action method that lets the user export the contents of
 *              the framework database to a text file.
 */
- (IBAction)exportDatabase:(id)sender;


#pragma mark -
#pragma mark Private action methods (for debugging only)

/*!
 * @method      _testParser:
 * @discussion  For debugging purposes only -- not exposed to general
 *              users.  Opens a window in which you can select a file and
 *              see the results of attempting to parse the file.
 */
- (IBAction)_testParser:(id)sender;  // [agl] uses AKDebugUtils

/*!
 * @method      _testParser:
 * @discussion  For debugging purposes only -- not exposed to general
 *              users.  Prints the current key view loop to the log.
 */
- (IBAction)_printKeyViewLoop:(id)sender;

@end
