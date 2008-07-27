/*
 * AKWindowLayout.h
 *
 * Created by Andy Lee on Sat Jun 14 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

/*!
 * @class       AKWindowLayout
 * @abstract    Specifies visual attributes of a browser window.
 * @discussion  Specifies the window's size and position, the layout of
 *              its subviews, and flags such as the selected quicklist
 *              mode and the Search flag settings.
 */
@interface AKWindowLayout : NSObject
{
    // General window attributes.
    NSRect _windowFrame;
    BOOL _toolbarIsVisible;

    // Attributes of the browser section.
    BOOL _browserIsVisible;
    float _browserFraction;
    int _numberOfBrowserColumns;

    // Attributes of the middle section.
    float _middleViewHeight;

    // Attributes of the quicklist drawer.
    BOOL _quicklistDrawerIsOpen;
    float _quicklistDrawerWidth;
    int _quicklistMode;
    NSString *_frameworkPopupSelection;
    BOOL _searchIncludesClasses;
    BOOL _searchIncludesMembers;
    BOOL _searchIncludesFunctions;
    BOOL _searchIncludesGlobals;
    BOOL _searchIgnoresCase;
}

//-------------------------------------------------------------------------
// Preferences
//-------------------------------------------------------------------------

+ (AKWindowLayout *)fromPrefDictionary:(NSDictionary *)prefDictionary;

- (NSDictionary *)asPrefDictionary;

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSRect)windowFrame;
- (void)setWindowFrame:(NSRect)frame;

- (BOOL)toolbarIsVisible;
- (void)setToolbarIsVisible:(BOOL)flag;

- (BOOL)browserIsVisible;
- (void)setBrowserIsVisible:(BOOL)flag;

- (float)browserFraction;
- (void)setBrowserFraction:(float)height;

- (int)numberOfBrowserColumns;
- (void)setNumberOfBrowserColumns:(int)numColumns;

- (float)middleViewHeight;
- (void)setMiddleViewHeight:(float)height;

- (BOOL)quicklistDrawerIsOpen;
- (void)setQuicklistDrawerIsOpen:(BOOL)flag;

- (float)quicklistDrawerWidth;
- (void)setQuicklistDrawerWidth:(float)width;

- (int)quicklistMode;
- (void)setQuicklistMode:(int)mode;

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
