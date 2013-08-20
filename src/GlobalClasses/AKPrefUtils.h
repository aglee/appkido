/*
 * AKPrefUtils.h
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "DIGSPrefUtils.h"

#import "AKPrefConstants.h"

/*!
 * Convenience methods for accessing AppKiDo-specific user preferences in the
 * defaults database.
 */
@interface AKPrefUtils : DIGSPrefUtils

#pragma mark -
#pragma mark AppKiDo preferences

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

#pragma mark -
#pragma mark Clearing groups of preferences

/*! Resets all user preferences to their default values. */
+ (void)resetAllPrefsToDefaults;

/*! Resets only the Appearance prefs to their default values. */
+ (void)resetAppearancePrefsToDefaults;

/*! Resets only the Navigation prefs to their default values. */
+ (void)resetNavigationPrefsToDefaults;

/*! Resets only the Frameworks prefs to their default values. */
+ (void)resetFrameworksPrefsToDefaults;

/*! Resets only the Search prefs to their default values. */
+ (void)resetSearchPrefsToDefaults;

@end
