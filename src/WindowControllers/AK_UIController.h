//
//  AK_UIController.h
//  AppKiDo
//
//  Created by Andy Lee on 2/26/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AKSavedWindowState;
@class AKWindowLayout;

/*!
 * Declares methods for performing common UI-related operations.
 */
@protocol AK_UIController <NSObject>

@required

/*! Applies the user's preference settings to the look of the UI. */
- (void)applyUserPreferences;

/*!
 * Returns YES if the specified UI item should be enabled. Expects anItem to be
 * either an NSMenuItem or an NSToolbarItem.
 */
- (BOOL)validateItem:(id)anItem;

- (void)takeWindowLayoutFrom:(AKWindowLayout *)windowLayout;
- (void)putWindowLayoutInto:(AKWindowLayout *)windowLayout;

@end

