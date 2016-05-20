/*
 * AKAppDelegate.h
 *
 * Created by Andy Lee on Thu Jun 27 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import "AKUIConfigurable.h"

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
@interface AKAppDelegate : NSObject <AKUIConfigurable, NSUserInterfaceValidations, NSApplicationDelegate>
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
}

#pragma mark - Shared instance

+ (AKAppDelegate *)appDelegate;

#pragma mark - Getters and setters

@property (readonly, strong) AKDatabase *appDatabase;

#pragma mark - Navigation

/*! If a text view has keyboard focus, returns that text view. */
@property (readonly, strong) NSTextView *selectedTextView;

/*! Search the window controller of the topmost browser window, or nil. */
@property (readonly, strong) AKWindowController *frontmostWindowController;

/*! Opens a new browser window.  Returns the newly created window controller. */
@property (readonly, strong) AKWindowController *controllerForNewWindow;

#pragma mark - Search

- (void)performExternallyRequestedSearchForString:(NSString *)searchString;

#pragma mark - AppleScript support

- (id)handleSearchScriptCommand:(NSScriptCommand *)aCommand;

#pragma mark - Managing the user's Favorites list

/*! Returns AKDocLocators for the items in the user's Favorites list. */
@property (readonly, copy) NSArray *favoritesList;

- (void)addFavorite:(AKDocLocator *)docLocator;

- (void)removeFavoriteAtIndex:(NSInteger)favoritesIndex;

- (void)moveFavoriteFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

#pragma mark - Action methods

- (IBAction)openAboutPanel:(id)sender;

- (IBAction)checkForNewerVersion:(id)sender;

- (IBAction)openPrefsPanel:(id)sender;

- (IBAction)openNewWindow:(id)sender;

/*! Expects sender to be an NSMenuItem with an NSURL as representedObject. */
- (IBAction)openLinkInNewWindow:(id)sender;

/*!
 * If a text view is first responder, scrolls it to show the selected text, if
 * any.
 */
- (IBAction)scrollToTextSelection:(id)sender;  //TODO: Doesn't seem to be used anywhere.  Remove?

/*! Prompts for a file name and exports the contents of the database as XML. */
- (IBAction)exportDatabase:(id)sender;

/*! Displays a random API symbol to test the user's knowledge. */
- (IBAction)popQuiz:(id)sender;

@end
