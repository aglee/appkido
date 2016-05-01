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
{
@private
    // General window attributes.
    NSRect _windowFrame;
    BOOL _toolbarIsVisible;

    // Attributes of the browser section.
    BOOL _browserIsVisible;
    CGFloat _browserFraction;
    CGFloat _browserHeight;
    NSInteger _numberOfBrowserColumns;

    // Attributes of the middle section.
    CGFloat _middleViewHeight;
    CGFloat _subtopicListWidth;  // This is an attribute being added in March 2013.

    // Attributes of the quicklist drawer.
    BOOL _quicklistDrawerIsOpen;
    CGFloat _quicklistDrawerWidth;
    NSInteger _quicklistMode;
    NSString *_frameworkPopupSelection;
    BOOL _searchIncludesClasses;
    BOOL _searchIncludesMembers;
    BOOL _searchIncludesFunctions;
    BOOL _searchIncludesGlobals;
    BOOL _searchIgnoresCase;
}

@property (nonatomic, assign) NSRect windowFrame;
@property (nonatomic, assign) BOOL toolbarIsVisible;
@property (nonatomic, assign) BOOL browserIsVisible;
@property (nonatomic, assign) CGFloat browserFraction;
@property (nonatomic, assign) CGFloat browserHeight;
@property (nonatomic, assign) NSInteger numberOfBrowserColumns;
@property (nonatomic, assign) CGFloat middleViewHeight;
@property (nonatomic, assign) CGFloat subtopicListWidth;
@property (nonatomic, assign) BOOL quicklistDrawerIsOpen;
@property (nonatomic, assign) CGFloat quicklistDrawerWidth;
@property (nonatomic, assign) NSInteger quicklistMode;
@property (nonatomic, copy) NSString *frameworkPopupSelection;
@property (nonatomic, assign) BOOL searchIncludesClasses;
@property (nonatomic, assign) BOOL searchIncludesMembers;
@property (nonatomic, assign) BOOL searchIncludesFunctions;
@property (nonatomic, assign) BOOL searchIncludesGlobals;
@property (nonatomic, assign) BOOL searchIgnoresCase;

#pragma mark -
#pragma mark Getters and setters

- (NSRect)windowFrame;
- (void)setWindowFrame:(NSRect)frame;

- (BOOL)toolbarIsVisible;
- (void)setToolbarIsVisible:(BOOL)flag;

- (BOOL)browserIsVisible;
- (void)setBrowserIsVisible:(BOOL)flag;

- (CGFloat)browserFraction;
- (void)setBrowserFraction:(CGFloat)height;

- (NSInteger)numberOfBrowserColumns;
- (void)setNumberOfBrowserColumns:(NSInteger)numColumns;

- (CGFloat)middleViewHeight;
- (void)setMiddleViewHeight:(CGFloat)height;

- (BOOL)quicklistDrawerIsOpen;
- (void)setQuicklistDrawerIsOpen:(BOOL)flag;

- (CGFloat)quicklistDrawerWidth;
- (void)setQuicklistDrawerWidth:(CGFloat)width;

- (NSInteger)quicklistMode;
- (void)setQuicklistMode:(NSInteger)mode;

- (NSString *)frameworkPopupSelection;
- (void)setFrameworkPopupSelection:(NSString *)frameworkName;

- (BOOL)searchIncludesClasses;
- (void)setSearchIncludesClasses:(BOOL)flag;

- (BOOL)searchIncludesMembers;
- (void)setSearchIncludesMembers:(BOOL)flag;

- (BOOL)searchIncludesFunctions;
- (void)setSearchIncludesFunctions:(BOOL)flag;

- (BOOL)searchIncludesGlobals;
- (void)setSearchIncludesGlobals:(BOOL)flag;

- (BOOL)searchIgnoresCase;
- (void)setSearchIgnoresCase:(BOOL)flag;

@end
