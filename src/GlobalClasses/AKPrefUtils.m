/*
 * AKPrefUtils.m
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKPrefUtils.h"

#import <DIGSLog.h>
#import "AKFrameworkConstants.h"
#import "AKPrefConstants.h"


//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface AKPrefUtils (Private)
+ (void)_registerStandardDefaults;
@end


@implementation AKPrefUtils

//-------------------------------------------------------------------------
// Class initialization
//-------------------------------------------------------------------------

+ (void)initialize
{
    // Tell NSUserDefaults the standard values for user preferences.
    [self _registerStandardDefaults];

    // Set logging verbosity, based on user preferences.
    DIGSSetVerbosityLevel(
        [[NSUserDefaults standardUserDefaults]
            integerForKey:(id)DIGSLogVerbosityUserDefault]);
//    NSLog(@"AppKiDo log level is %d", DIGSGetVerbosityLevel());
}

//-------------------------------------------------------------------------
// App-specific getters and setters
//-------------------------------------------------------------------------

+ (NSArray *)selectedFrameworkNamesPref
{
    NSMutableArray *fwNames =
        [NSMutableArray
            arrayWithArray:
                [self arrayValueForPref:AKSelectedFrameworksPrefName]];
    
    // In older versions, "AppKit" was saved as "ApplicationKit" in prefs.
    unsigned index = [fwNames indexOfObject:@"ApplicationKit"];
    if (index != NSNotFound)
    {
        [fwNames removeObjectAtIndex:index];
        [fwNames
            insertObject:AKAppKitFrameworkName
            atIndex:index];
    }

    // It seems prefs files can be messed up from earlier app versions.  In
    // particular, required frameworks can be missing from the prefs setting.
    // Thanks to Gerriet for pointing this out.
    NSEnumerator *essentialFrameworkNamesEnum =
        [AKNamesOfEssentialFrameworks() objectEnumerator];
    NSString *essentialFrameworkName;

    while ((essentialFrameworkName = [essentialFrameworkNamesEnum nextObject]))
    {
        if (![fwNames containsObject:essentialFrameworkName])
        {
            [fwNames addObject:essentialFrameworkName];
        };
    } 

    return fwNames;
}

+ (void)setSelectedFrameworkNamesPref:(NSArray *)fwNames
{
    [self setArrayValue:fwNames forPref:AKSelectedFrameworksPrefName];
}

+ (NSString *)devToolsPathPref
{
    return [self stringValueForPref:AKDevToolsPathPrefName];
}

+ (void)setDevToolsPathPref:(NSString *)dir
{
    [self setStringValue:dir forPref:AKDevToolsPathPrefName];
}

//-------------------------------------------------------------------------
// Clearing preferences
//-------------------------------------------------------------------------

+ (void)resetAllPrefsToDefaults
{
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];

    [userPrefs removeObjectForKey:(id)DIGSLogVerbosityUserDefault];
    [userPrefs removeObjectForKey:AKDevToolsPathPrefName];

    [self resetAppearancePrefsToDefaults];
    [self resetNavigationPrefsToDefaults];
    [self resetFrameworksPrefsToDefaults];
    [self resetSearchPrefsToDefaults];
}

+ (void)resetAppearancePrefsToDefaults
{
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];

    [userPrefs removeObjectForKey:AKLayoutForNewWindowsPrefName];
    [userPrefs removeObjectForKey:AKSavedWindowStatesPrefName];
    [userPrefs removeObjectForKey:AKListFontNamePrefName];
    [userPrefs removeObjectForKey:AKListFontSizePrefName];
    [userPrefs removeObjectForKey:AKHeaderFontNamePrefName];
    [userPrefs removeObjectForKey:AKHeaderFontSizePrefName];
    [userPrefs removeObjectForKey:AKDocMagnificationPrefName];
    [userPrefs removeObjectForKey:AKUseTexturedWindowsPrefName];
}

+ (void)resetNavigationPrefsToDefaults
{
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];

    [userPrefs removeObjectForKey:AKMaxHistoryPrefName];
//    [userPrefs removeObjectForKey:AKFavoritesPrefName];
}

+ (void)resetFrameworksPrefsToDefaults
{
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];

    [userPrefs removeObjectForKey:AKSelectedFrameworksPrefName];
}

+ (void)resetSearchPrefsToDefaults
{
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];

    [userPrefs removeObjectForKey:AKMaxSearchStringsPrefName];
    [userPrefs removeObjectForKey:AKIncludeClassesAndProtocolsPrefKey];
    [userPrefs removeObjectForKey:AKIncludeMethodsPrefKey];
    [userPrefs removeObjectForKey:AKIncludeFunctionsPrefKey];
    [userPrefs removeObjectForKey:AKIncludeGlobalsPrefKey];
    [userPrefs removeObjectForKey:AKIgnoreCasePrefKey];
}

@end

//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation AKPrefUtils (Private)

// Register the default values for all user preferences, i.e., the
// value to use for each preference unless the user specifies a
// different one.
//
// Note: we don't assign a default value for
// AKLayoutForNewWindowsPrefName, because the default to use is
// whatever is in the nib file.
//
// We also don't create an entry for AKSavedWindowStatesPrefName,
// because the default for this is simply the empty list.
+ (void)_registerStandardDefaults
{
    NSMutableDictionary *defaultPrefsDictionary
        = [NSMutableDictionary dictionary];

    [defaultPrefsDictionary
        setObject:[NSNumber numberWithInt:DIGS_VERBOSITY_WARNING]
        forKey:(id)DIGSLogVerbosityUserDefault];

    [defaultPrefsDictionary
        setObject:@"/Developer"
        forKey:AKDevToolsPathPrefName];

    [defaultPrefsDictionary
        setObject:[NSNumber numberWithInt:20]
        forKey:AKMaxSearchStringsPrefName];

    [defaultPrefsDictionary
        setObject:[NSNumber numberWithBool:YES]
        forKey:AKIncludeClassesAndProtocolsPrefKey];

    [defaultPrefsDictionary
        setObject:[NSNumber numberWithBool:YES]
        forKey:AKIncludeMethodsPrefKey];

    [defaultPrefsDictionary
        setObject:[NSNumber numberWithBool:YES]
        forKey:AKIncludeFunctionsPrefKey];

    [defaultPrefsDictionary
        setObject:[NSNumber numberWithBool:YES]
        forKey:AKIncludeGlobalsPrefKey];

    [defaultPrefsDictionary
        setObject:[NSNumber numberWithBool:YES]
        forKey:AKIgnoreCasePrefKey];

    [defaultPrefsDictionary
        setObject:@"Helvetica"
        forKey:AKListFontNamePrefName];

    [defaultPrefsDictionary
        setObject:[NSNumber numberWithInt:12]
        forKey:AKListFontSizePrefName];

    [defaultPrefsDictionary
        setObject:@"Monaco"
        forKey:AKHeaderFontNamePrefName];

    [defaultPrefsDictionary
        setObject:[NSNumber numberWithInt:10]
        forKey:AKHeaderFontSizePrefName];

    [defaultPrefsDictionary
        setObject:[NSNumber numberWithInt:100]
        forKey:AKDocMagnificationPrefName];

    [defaultPrefsDictionary
        setObject:[NSNumber numberWithBool:YES]
        forKey:AKUseTexturedWindowsPrefName];

    [defaultPrefsDictionary
        setObject:[NSNumber numberWithInt:50]
        forKey:AKMaxHistoryPrefName];

    [defaultPrefsDictionary
        setObject:[NSArray array]
        forKey:AKFavoritesPrefName];

    [defaultPrefsDictionary
        setObject:AKNamesOfEssentialFrameworks()
        forKey:AKSelectedFrameworksPrefName];

    [[NSUserDefaults standardUserDefaults]
        registerDefaults:defaultPrefsDictionary];
}

@end
