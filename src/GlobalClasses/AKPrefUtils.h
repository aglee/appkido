/*
 * AKPrefUtils.h
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import "DIGSPrefUtils.h"
#import "AKPrefConstants.h"

/*!
 * @class       AKPrefUtils
 * @discussion  Convenience methods for accessing AppKiDo user preferences
 *              in the defaults database.
 */
@interface AKPrefUtils : DIGSPrefUtils

#pragma mark - AppKiDo preferences

/*! Which frameworks we should display docs for. */
+ (NSArray *)selectedFrameworkNamesPref;
+ (void)setSelectedFrameworkNamesPref:(NSArray *)fwNames;

/*! We look for the CoreReference docset within the Dev Tools directory. */
+ (NSString *)devToolsPathPref;
+ (void)setDevToolsPathPref:(NSString *)dir;

/*! See AKDevTools for where the SDK version comes from. */
+ (NSString *)sdkVersionPref;
+ (void)setSDKVersionPref:(NSString *)dir;

/*!
 * Should we open a new window when there's an external search request
 * (via AppleScript or system service)?
 */
+ (BOOL)shouldSearchInNewWindow;
+ (void)setShouldSearchInNewWindow:(BOOL)flag;

#pragma mark - Clearing groups of preferences

/*!
 * @method      resetAllPrefsToDefaults
 * @discussion  Resets all user preferences to their default values.
 */
+ (void)resetAllPrefsToDefaults;

/*!
 * @method      resetAppearancePrefsToDefaults
 * @discussion  Resets only the Appearance prefs to their default values.
 */
+ (void)resetAppearancePrefsToDefaults;

/*!
 * @method      resetNavigationPrefsToDefaults
 * @discussion  Resets only the Navigation prefs to their default values.
 */
+ (void)resetNavigationPrefsToDefaults;

/*!
 * @method      resetFrameworksPrefsToDefaults
 * @discussion  Resets only the Frameworks prefs to their default values.
 */
+ (void)resetFrameworksPrefsToDefaults;

/*!
 * @method      resetSearchPrefsToDefaults
 * @discussion  Resets only the Search prefs to their default values.
 */
+ (void)resetSearchPrefsToDefaults;

@end
