/*
 * AKPrefUtils.m
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKPrefUtils.h"

#import "DIGSLog.h"
#import "AKFrameworkConstants.h"
#import "AKDevToolsUtils.h"

@implementation AKPrefUtils

#pragma mark - Class initialization

+ (void)initialize
{
    // Tell NSUserDefaults the standard values for user preferences.
    [self _registerStandardDefaults];

    // Set logging verbosity, based on user preferences.
    DIGSSetVerbosityLevel( [[NSUserDefaults standardUserDefaults] integerForKey:(id)DIGSLogVerbosityUserDefault]);
//    NSLog(@"AppKiDo log level is %d", DIGSGetVerbosityLevel());
}

#pragma mark - AppKiDo preferences

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

#pragma mark - Clearing groups of preferences

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

#pragma mark - Private methods

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

    [defaultPrefsDictionary setObject:[NSNumber numberWithInt:DIGS_VERBOSITY_WARNING]
                               forKey:(id)DIGSLogVerbosityUserDefault];

    [defaultPrefsDictionary setObject:[self _defaultDevToolsPath]
                               forKey:AKDevToolsPathPrefName];

    [defaultPrefsDictionary setObject:[NSNumber numberWithBool:NO]
                               forKey:AKSearchInNewWindowPrefName];

    [defaultPrefsDictionary setObject:[NSNumber numberWithInt:20]
                               forKey:AKMaxSearchStringsPrefName];

    [defaultPrefsDictionary setObject:[NSNumber numberWithBool:YES]
                               forKey:AKIncludeClassesAndProtocolsPrefKey];

    [defaultPrefsDictionary setObject:[NSNumber numberWithBool:YES]
                               forKey:AKIncludeMethodsPrefKey];

    [defaultPrefsDictionary setObject:[NSNumber numberWithBool:YES]
                               forKey:AKIncludeFunctionsPrefKey];

    [defaultPrefsDictionary setObject:[NSNumber numberWithBool:YES]
                               forKey:AKIncludeGlobalsPrefKey];

    [defaultPrefsDictionary setObject:[NSNumber numberWithBool:YES]
                               forKey:AKIgnoreCasePrefKey];

    [defaultPrefsDictionary setObject:@"Lucida Grande"
                               forKey:AKListFontNamePrefName];

    [defaultPrefsDictionary setObject:[NSNumber numberWithInt:12]
                               forKey:AKListFontSizePrefName];

    [defaultPrefsDictionary setObject:@"Monaco"
                               forKey:AKHeaderFontNamePrefName];

    [defaultPrefsDictionary setObject:[NSNumber numberWithInt:10]
                               forKey:AKHeaderFontSizePrefName];

    [defaultPrefsDictionary setObject:[NSNumber numberWithInt:100]
                               forKey:AKDocMagnificationPrefName];
    
    [defaultPrefsDictionary setObject:[NSNumber numberWithBool:YES]
                               forKey:AKUseTexturedWindowsPrefName];
    
    [defaultPrefsDictionary setObject:[NSNumber numberWithInt:50]
                               forKey:AKMaxHistoryPrefName];
    
    [defaultPrefsDictionary setObject:[NSArray array]
                               forKey:AKFavoritesPrefName];

// Don't register a default for the selected-frameworks pref.  We'll set it
// in -[AKAppController awakeFromNib] if it hasn't been set.  We do it there
// because we may have to query the AKDatabase for the frameworks to use.
//    [defaultPrefsDictionary
//        setObject:AKNamesOfEssentialFrameworks
//        forKey:AKSelectedFrameworksPrefName];

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefsDictionary];
}

+ (NSString *)_defaultDevToolsPath
{
    NSString *xcodeSelectPath = [AKDevToolsUtils pathReturnedByXcodeSelect];

    if ([xcodeSelectPath length] == 0)
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
