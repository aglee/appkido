/*
 * AKAppController.h
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import "AKUIController.h"

@class AKAboutWindowController;
@class AKDatabase;
@class AKDocLocator;
@class AKPrefPanelController;
@class AKSplashWindowController;
@class AKWindowController;

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
@interface AKAppController : NSObject <AKUIController>
{
@private
    AKDatabase *_appDatabase;

    AKSplashWindowController *_splashWindowController;
    NSOperationQueue *_operationQueue;

    BOOL _finishedInitializing;  // Becomes true when -awakeFromNib finishes.
    AKPrefPanelController *_prefPanelController;  // Lazily instantiated.
    AKAboutWindowController *_aboutWindowController;  // Lazily instantiated.

    // Elements are AKWindowControllers.
    NSMutableArray *_windowControllers;

    // Elements are AKDocLocators.
    NSMutableArray *_favoritesList;

    // IB outlets.
    IBOutlet NSMenuItem *_firstGoMenuDivider;
}

#pragma mark -
#pragma mark Application startup

/*!
 * Called by applicationDidFinishLaunching: -- and possibly again by
 * finishApplicationStartup if it finds something amiss with the database.
 */
- (void)startApplicationStartup;

/*!
 * Called by AKLoadDatabaseOperation after the docset has been loaded into the
 * database.
 */
- (void)finishApplicationStartup;

#pragma mark -
#pragma mark Getters and setters

- (AKDatabase *)appDatabase;

#pragma mark -
#pragma mark Navigation

/*! If a text view has keyboard focus, returns that text view. */
- (NSTextView *)selectedTextView;

/*! Search the window controller of the topmost browser window, or nil. */
- (AKWindowController *)frontmostWindowController;

/*! Opens a new browser window.  Returns the newly created window controller. */
- (AKWindowController *)controllerForNewWindow;

#pragma mark -
#pragma mark External search requests

- (void)searchForString:(NSString *)searchString;

#pragma mark -
#pragma mark AppleScript support

- (id)handleSearchScriptCommand:(NSScriptCommand *)aCommand;

#pragma mark -
#pragma mark Managing the user's Favorites list

/*! Returns AKDocLocators for the items in the user's Favorites list. */
- (NSArray *)favoritesList;

- (void)addFavorite:(AKDocLocator *)docLocator;

- (void)removeFavoriteAtIndex:(NSInteger)favoritesIndex;

- (void)moveFavoriteFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

#pragma mark -
#pragma mark Action methods

- (IBAction)openAboutPanel:(id)sender;

- (IBAction)checkForNewerVersion:(id)sender;

- (IBAction)openPrefsPanel:(id)sender;

- (IBAction)openNewWindow:(id)sender;

/*!
 * If a text view is first responder, scrolls it to show the selected text, if
 * any.
 */
- (IBAction)scrollToTextSelection:(id)sender;

/*! Prompts for a file name and exports the contents of the database as XML. */
- (IBAction)exportDatabase:(id)sender;

#pragma mark -
#pragma mark Action methods for debugging only

/*!
 * For debugging purposes only. Opens a window in which you can select a file
 * and see how the file gets parsed.
 */
- (IBAction)_testParser:(id)sender;

/*! For debugging purposes only. Logs the current key view loop to the log. */
- (IBAction)_printKeyViewLoop:(id)sender;

@end
