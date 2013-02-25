/*
 * AKTableView.h
 *
 * Created by Andy Lee on Wed May 28 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <AppKit/AppKit.h>

@interface AKTableView : NSTableView

#pragma mark -
#pragma mark Preferences

/*! Applies the font indicated by the user's preference settings. */
- (void)applyListFontPrefs;

@end
