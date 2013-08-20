/*
 * AKAppDelegate.h
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
 * AppKiDo's application delegate. On launch, displays the splash window, loads
 * the database, and loads window states remembered from the previous launch.
 * On quit, saves the states of all open windows.
 */
@interface AKAppDelegate : NSObject <AKUIController>
{
@private
    AKDatabase *_appDatabase;

    // Displayed while the database is loading.
    AKSplashWindowController *_splashWindowController;

    // For loading the database asynchronously.
    NSOperationQueue *_operationQueue;

    // Becomes true when -awakeFromNib finishes.
    BOOL _finishedInitializing;

    // Single-instance windows, lazily instantiated.
    AKPrefPanelController *_prefPanelController;
    AKAboutWindowController *_aboutWindowController;

    // Elements are AKWindowControllers.
    NSMutableArray *_windowControllers;

    // Elements are AKDocLocators.
    NSMutableArray *_favoritesList;

    // IB outlets.
    NSMenuItem *_firstGoMenuDivider;
}

/*! We insert menu items after this item in the "Go" menu. */
@property (nonatomic, assign) IBOutlet NSMenuItem *firstGoMenuDivider;

#pragma mark -
#pragma mark Shared instance

+ (AKAppDelegate *)appDelegate;

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
#pragma mark Search

- (void)performExternallyRequestedSearchForString:(NSString *)searchString;

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

/*! Expects sender to be an NSMenuItem with an NSURL as representedObject. */
- (IBAction)openLinkInNewWindow:(id)sender;

/*!
 * If a text view is first responder, scrolls it to show the selected text, if
 * any. [agl] Doesn't seem to be used anywhere.
 */
- (IBAction)scrollToTextSelection:(id)sender;

/*! Prompts for a file name and exports the contents of the database as XML. */
- (IBAction)exportDatabase:(id)sender;

/*! Displays a random API symbol to test the user's knowledge. */
- (IBAction)popQuiz:(id)sender;

@end
