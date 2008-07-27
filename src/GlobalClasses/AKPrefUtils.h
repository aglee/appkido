/*
 * AKPrefUtils.h
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import <DIGSPrefUtils.h>
#import "AKPrefConstants.h"

/*!
 * @class       AKPrefUtils
 * @discussion  Utility methods for getting and setting user preferences.
 *              These are mostly wrappers around NSUserDefaults methods.
 */
@interface AKPrefUtils : DIGSPrefUtils
{
}

//-------------------------------------------------------------------------
// App-specific getters and setters
//-------------------------------------------------------------------------

+ (NSArray *)selectedFrameworkNamesPref;
+ (void)setSelectedFrameworkNamesPref:(NSArray *)fwNames;

/*! We look for the CoreReference docset within the Dev Tools directory. */
+ (NSString *)devToolsPathPref;
+ (void)setDevToolsPathPref:(NSString *)dir;

//-------------------------------------------------------------------------
// Clearing preferences
//-------------------------------------------------------------------------

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
