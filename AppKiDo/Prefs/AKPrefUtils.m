/*
 * AKPrefUtils.m
 *
 * Created by Andy Lee on Fri Jun 20 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKPrefUtils.h"
#import "AKFrameworkConstants.h"
#import "ALSimpleTask.h"
#import "DIGSLog.h"
#import "NSString+AppKiDo.h"

@implementation AKPrefUtils

#pragma mark - Class initialization

+ (void)initialize
{
	// Tell NSUserDefaults the standard values for user preferences.
	[self _registerStandardDefaults];

	// Set logging verbosity, based on user preferences.
	DIGSSetVerbosityLevel( [[NSUserDefaults standardUserDefaults] integerForKey:DIGSLogVerbosityUserDefault]);
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

+ (NSString *)xcodePathPref
{
	return [self stringValueForPref:AKXcodePathPrefName];
}

+ (void)setXcodePathPref:(NSString *)dir
{
	[self setStringValue:dir forPref:AKXcodePathPrefName];
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

	[userPrefs removeObjectForKey:DIGSLogVerbosityUserDefault];
	[userPrefs removeObjectForKey:AKXcodePathPrefName];
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
//	[userPrefs removeObjectForKey:AKFavoritesPrefName];
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

	defaultPrefsDictionary[DIGSLogVerbosityUserDefault] = @(DIGS_VERBOSITY_WARNING);

	defaultPrefsDictionary[AKXcodePathPrefName] = @"/Applications/Xcode.app";

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
	NSString *xcodeSelectPath = [self _pathReturnedByXcodeSelect];

	if (xcodeSelectPath.length == 0)
	{
		// We got nothing from xcode-select, so return a hard-coded default.
		return @"/Applications/Xcode.app/Contents/Developer";
	}
	else
	{
		return nil; // [AKDevToolsUtils devToolsPathFromPossibleXcodePath:xcodeSelectPath];
	}
}

//TODO: Moved here from the now defunct AKDevToolsUtils.m.
// Facts about xcode-select:
//
// "xcode-select -print-path" looks for /usr/share/xcode-select/xcode_dir_path.
// If it finds the file, it returns the file's contents. Otherwise it returns
// /Applications/Xcode.app/Contents/Developer. The file doesn't exist until you
// run "xcode-select -switch".
//
// "xcode-select -switch" examines the path you give it. It fails if the path
// doesn't exist. If the path points to an Xcode.app that is 4.3 or later, it
// adds "Contents/Developer" for you; otherwise it leaves the path alone. It
// stores the path (possibly modified) in the xcode_dir_path file.
//
// I originally found out about xcode_dir_path because xcode-select was a shell
// script, so I could read what it did. xcode-select is now a binary executable,
// but you can still get some clues by running "strings" on it. See here for
// yet another way to find out about the xcode_dir_path file:
// <http://stackoverflow.com/questions/14609738/where-does-xcode-select-stores-information>
// In particular, the command
//
//      dtruss -f -t open xcode-select -print-path
//
// to print all syscalls to "open".
//
// Useful and/or interesting commands:
//      xcode-select -print-path
//      sudo xcode-select -switch SomePath
//      sudo rm -f /usr/share/xcode-select/xcode_dir_path
//      strings `which xcode-select`
//
+ (NSString *)_pathReturnedByXcodeSelect
{
	// The reason I invoked xcode-select via bash was that there is an environment variable,
	// DEVELOPER_DIR, that, if set, overrides the Xcode path.  The problem is: if a person's
	// .bashrc executes commands that have output, this throws off my extracting of the Xcode
	// path from that output.  And in any case, people might not have bash as their primary
	// shell.  So, better to call xcode-select directly after all.  The user can always use
	// the prefs panel to select a different Xcode.
	//
	// On 2013-06-16, blenko sent an alternate solution: "My fix, in APDevToolUtils.m at line
	// 46, add @"--noprofile", as an argument to bash (it must appear before the -l and -c
	// arguments)."  But the original point was to pick up any value that bash startup sets
	// for DEVELOPER_DIR, so it's simpler just to not use bash at all.  Still, nice to know
	// about --noprofile.
	//
	//	ALSimpleTask *tw = [[[ALSimpleTask alloc] initWithCommandPath:@"/bin/bash"
	//                                                        arguments:(@[
	//                                                                   @"-l",
	//                                                                   @"-c",
	//                                                                   @"echo -n `/usr/bin/xcode-select -print-path`"
	//                                                                   ])]
	//                        autorelease];

	// Note: passing either -print-path or --print-path works when calling xcode-select
	// from a shell, but only --print-path works when using NSTask.
	ALSimpleTask *task = [[ALSimpleTask alloc] initWithCommandPath:@"/usr/bin/xcode-select"
														 arguments:@[ @"--print-path" ]];
	if (![task runTask]) {
		NSLog(@"Failed to launch xcode-select. Reason: %@.", task.outputString);
		return nil;
	}

	if (task.exitStatus != 0) {
		NSLog(@"xcode-select failed with exit status %d.", task.exitStatus);
		return nil;
	}

	return [task.outputString ak_trimWhitespace];
}

@end
