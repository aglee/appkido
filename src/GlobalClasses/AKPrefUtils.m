/*
 * AKPrefUtils.m
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKPrefUtils.h"

#import "DIGSLog.h"

#import "AKDevToolsUtils.h"
#import "AKFrameworkConstants.h"

@implementation AKPrefUtils

#pragma mark -
#pragma mark Class initialization

+ (void)initialize
{
    // Tell NSUserDefaults the standard values for user preferences.
    [self _registerStandardDefaults];

    // Set logging verbosity, based on user preferences.
    DIGSSetVerbosityLevel( [[NSUserDefaults standardUserDefaults] integerForKey:(id)DIGSLogVerbosityUserDefault]);
//    NSLog(@"AppKiDo log level is %d", DIGSGetVerbosityLevel());
}

#pragma mark -
#pragma mark AppKiDo preferences

+ (NSArray *)selectedFrameworkNamesPref
{
    // Note that if you pass nil to -arrayWithArray:, it returns an empty
    // array rather than nil.
    NSArray *prefArray = [self arrayValueForPref:AKSelectedFrameworksPrefName];

    if (prefArray == nil)
    {
        return nil;
    }

    NSMutableArray *fwNames = [NSMutableArray arrayWithArray:prefArray];
    
    // In older versions, "AppKit" was saved as "ApplicationKit" in prefs.
    NSUInteger frameworkIndex = [fwNames indexOfObject:@"ApplicationKit"];
    if (frameworkIndex != NSNotFound)
    {
        [fwNames removeObjectAtIndex:frameworkIndex];
        [fwNames insertObject:AKAppKitFrameworkName atIndex:frameworkIndex];
    }

    // It seems prefs files can be messed up from earlier app versions.  In
    // particular, required frameworks can be missing from the prefs setting.
    // Thanks to Gerriet for pointing this out.
    for (NSString *essentialFrameworkName in AKNamesOfEssentialFrameworks)
    {
        if (![fwNames containsObject:essentialFrameworkName])
        {
            [fwNames addObject:essentialFrameworkName];
        }
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

+ (NSString *)sdkVersionPref
{
    return [self stringValueForPref:AKSDKVersionPrefName];
}

+ (void)setSDKVersionPref:(NSString *)dir
{
    [self setStringValue:dir forPref:AKSDKVersionPrefName];
}

+ (BOOL)shouldSearchInNewWindow
{
    return [self boolValueForPref:AKSearchInNewWindowPrefName];
}

+ (void)setShouldSearchInNewWindow:(BOOL)flag
{
    [self setBoolValue:flag forPref:AKSearchInNewWindowPrefName];
}

#pragma mark -
#pragma mark Clearing groups of preferences

+ (void)resetAllPrefsToDefaults
{
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];

    [userPrefs removeObjectForKey:(id)DIGSLogVerbosityUserDefault];
    [userPrefs removeObjectForKey:AKDevToolsPathPrefName];
    [userPrefs removeObjectForKey:AKSearchInNewWindowPrefName];

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

#pragma mark -
#pragma mark Private methods

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
    NSMutableDictionary *defaultPrefsDictionary = [NSMutableDictionary dictionary];

    defaultPrefsDictionary[(id)DIGSLogVerbosityUserDefault] = @(DIGS_VERBOSITY_WARNING);

    defaultPrefsDictionary[AKDevToolsPathPrefName] = [self _defaultDevToolsPath];

    defaultPrefsDictionary[AKSearchInNewWindowPrefName] = @NO;

    defaultPrefsDictionary[AKMaxSearchStringsPrefName] = @20;

    defaultPrefsDictionary[AKIncludeClassesAndProtocolsPrefKey] = @YES;

    defaultPrefsDictionary[AKIncludeMethodsPrefKey] = @YES;

    defaultPrefsDictionary[AKIncludeFunctionsPrefKey] = @YES;

    defaultPrefsDictionary[AKIncludeGlobalsPrefKey] = @YES;

    defaultPrefsDictionary[AKIgnoreCasePrefKey] = @YES;

    defaultPrefsDictionary[AKListFontNamePrefName] = @"Lucida Grande";

    defaultPrefsDictionary[AKListFontSizePrefName] = @12;

    defaultPrefsDictionary[AKHeaderFontNamePrefName] = @"Monaco";

    defaultPrefsDictionary[AKHeaderFontSizePrefName] = @10;

    defaultPrefsDictionary[AKDocMagnificationPrefName] = @100;
    
    defaultPrefsDictionary[AKUseTexturedWindowsPrefName] = @YES;
    
    defaultPrefsDictionary[AKMaxHistoryPrefName] = @50;
    
    defaultPrefsDictionary[AKFavoritesPrefName] = @[];

// Don't register a default for the selected-frameworks pref.  We'll set it
// in -[AKAppDelegate awakeFromNib] if it hasn't been set.  We do it there
// because we may have to query the AKDatabase for the frameworks to use.
//    [defaultPrefsDictionary
//        setObject:AKNamesOfEssentialFrameworks
//        forKey:AKSelectedFrameworksPrefName];

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefsDictionary];
}

+ (NSString *)_defaultDevToolsPath
{
    NSString *xcodeSelectPath = [AKDevToolsUtils pathReturnedByXcodeSelect];

    if (xcodeSelectPath.length == 0)
    {
        // We got nothing from xcode-select, so return a hard-coded default.
        return @"/Applications/Xcode.app/Contents/Developer";
    }
    else
    {
        return [AKDevToolsUtils devToolsPathFromPossibleXcodePath:xcodeSelectPath];
    }
}

@end
