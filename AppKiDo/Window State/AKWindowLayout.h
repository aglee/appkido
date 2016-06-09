/*
 * AKWindowLayout.h
 *
 * Created by Andy Lee on Sat Jun 14 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import "AKPrefDictionary.h"

/*!
 * Specifies visual attributes of a browser window. These includes the window's
 * size and position, the layout of its subviews, the selected quicklist mode,
 * and the selected Search settings (such as whether to include classes in
 * search results).
 *
 * This is used in two places: to remember layouts of open windows so they can
 * be restored on relaunch, and to remember the user's preferred layout so it
 * can be applied to new windows.
 *
 * browserFraction is for backward compatibility. The real thing to use is
 * browserHeight.
 */
@interface AKWindowLayout : NSObject <AKPrefDictionary>

#pragma mark - General window attributes

@property (nonatomic, assign) NSRect windowFrame;
@property (nonatomic, assign) BOOL toolbarIsVisible;

#pragma mark - Browser section

@property (nonatomic, assign) BOOL browserIsVisible;
@property (nonatomic, assign) CGFloat browserFraction;
@property (nonatomic, assign) CGFloat browserHeight;
@property (nonatomic, assign) NSInteger numberOfBrowserColumns;

#pragma mark - Middle section

@property (nonatomic, assign) CGFloat middleViewHeight;
@property (nonatomic, assign) CGFloat subtopicListWidth;

#pragma mark - Quicklist drawer
@property (nonatomic, assign) BOOL quicklistDrawerIsOpen;
@property (nonatomic, assign) CGFloat quicklistDrawerWidth;
@property (nonatomic, assign) NSInteger quicklistMode;
@property (nonatomic, copy) NSString *frameworkPopupSelection;
@property (nonatomic, assign) BOOL searchIncludesClasses;
@property (nonatomic, assign) BOOL searchIncludesMembers;
@property (nonatomic, assign) BOOL searchIncludesFunctionsAndGlobals;
@property (nonatomic, assign) BOOL searchIgnoresCase;

@end
