/*
 *  AKDevToolsUtils.m
 *
 *  Created by Andy Lee on 1/25/08.
 *  Copyright 2008 Andy Lee. All rights reserved.
 */

#import "AKDevToolsUtils.h"

#import "ALSimpleTask.h"

@implementation AKDevToolsUtils

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
+ (NSString *)pathReturnedByXcodeSelect
{
	ALSimpleTask *tw = [[ALSimpleTask alloc] initWithCommandPath:@"/bin/bash"
													   arguments:(@[
																  @"-l",
																  @"-c",
																  @"echo -n `/usr/bin/xcode-select -print-path`"
																  ])];
	if (![tw runTask])
	{
		NSLog(@"Failed to launch xcode-select. Reason: %@.", [tw outputString]);
        return nil;
	}
    
    if ([tw exitStatus] != 0)
    {
		NSLog(@"xcode-select failed with exit status %d.", [tw exitStatus]);
        return nil;
    }

    return [tw outputString];
}

+ (NSString *)devToolsPathFromXcodeAppPath:(NSString *)xcodeAppPath
{
    // The order in which we check these two possibilities matters. Either kind
    // of xcodeAppPath will pass the second test.
    return ([self _devToolsPathFromStandaloneXcodeAppPath:xcodeAppPath]
            ?: [self _oldStyleDevToolsPathFromXcodeAppPath:xcodeAppPath]);
}

+ (NSString *)devToolsPathFromPossibleXcodePath:(NSString *)possibleXcodePath
{
    // Case 1: The given path isn't an app bundle. Assume it's a Dev Tools
    // directory and we don't have to do any adjusting.
    if (![[possibleXcodePath pathExtension] isEqualToString:@"app"])
    {
        return possibleXcodePath;
    }

    // Case 2: The given path is an Xcode app bundle, version 4.3 or higher,
    // meaning it contains all Dev Tools within the bundle.
    NSString *devToolsPath = [possibleXcodePath stringByAppendingPathComponent:@"Contents/Developer"];

    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:devToolsPath isDirectory:&isDir] && isDir) {
        return devToolsPath;
    }

    // Case 3: The given path is an Xcode.app bundle but not the standalone
    // type. Presumably it was selected from within a pre-4.3 Dev Tools
    // directory. Up to a certain version -- I forget when -- the Xcode path had
    // to be /Developer/Applications/Xcode.app, meaning we'd want to return
    // /Developer here. But then Apple started allowing a directory other than
    // /Developer to be the root Dev Tools directory, so we can't assume that.
    NSString *pathToDirContainingApp = [possibleXcodePath stringByDeletingLastPathComponent];
    NSString *nameOfDirContainingApp = [pathToDirContainingApp lastPathComponent];

    if ([nameOfDirContainingApp isEqualToString:@"Applications"])
    {
        return [pathToDirContainingApp stringByDeletingLastPathComponent];
    }

    // Case 4: The path is probably not a valid Dev Tools path, but we have to
    // return something.
    return possibleXcodePath;
}

+ (NSString *)xcodeAppPathFromDevToolsPath:(NSString *)devToolsPath
{
    return ([self _standaloneXcodeAppPathFromDevToolsPath:devToolsPath]
            ?: [self _xcodeAppPathFromOldStyleDevToolsPath:devToolsPath]);
}

#pragma mark - Private methods

// Checks for [xcodeAppPath]/Contents/Developer, which indicates we have a
// standalone Xcode that contains the Dev Tools.
+ (NSString *)_devToolsPathFromStandaloneXcodeAppPath:(NSString *)xcodeAppPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;

    NSString *pathWithinXcodeApp = [xcodeAppPath stringByAppendingPathComponent:@"Contents/Developer"];
    if ([fm fileExistsAtPath:pathWithinXcodeApp isDirectory:&isDir] && isDir)
    {
        return pathWithinXcodeApp;
    }
    else
    {
        return nil;
    }
}

// Checks for SOMEPATH/Applications/[xcodeAppPath], which indicates that the
// Xcode app lives in an old-style Dev Tools installation.
+ (NSString *)_oldStyleDevToolsPathFromXcodeAppPath:(NSString *)xcodeAppPath
{
    NSString *parentPath = [xcodeAppPath stringByDeletingLastPathComponent];

    if (![[parentPath lastPathComponent] isEqualToString:@"Applications"])
    {
        return nil;
    }

    NSString *parentOfApplicationsDir = [parentPath stringByDeletingLastPathComponent];

    if ([[NSFileManager defaultManager] fileExistsAtPath:parentOfApplicationsDir])
    {
        return parentOfApplicationsDir;
    }
    else
    {
        return nil;
    }
}

// Checks whether devToolsPath looks like SOMEPATH/SOMETHING.app/Contents/Developer.
+ (NSString *)_standaloneXcodeAppPathFromDevToolsPath:(NSString *)devToolsPath
{
    if (![[devToolsPath lastPathComponent] isEqualToString:@"Developer"])
    {
        return nil;
    }

    NSString *contentsDirPath = [devToolsPath stringByDeletingLastPathComponent];

    if (![[contentsDirPath lastPathComponent] isEqualToString:@"Contents"])
    {
        return nil;
    }

    NSString *xcodeAppPath = [contentsDirPath stringByDeletingLastPathComponent];

    if (![[xcodeAppPath pathExtension] isEqualToString:@"app"])
    {
        return nil;
    }

    if (![[NSFileManager defaultManager] fileExistsAtPath:xcodeAppPath])
    {
        return nil;
    }

    // If we got this far, we have an app. Assume it's Xcode.
    return xcodeAppPath;
}

// Looks for [devToolsPath]/Applications/SOMETHING.app/Contents/MacOS/Xcode.
+ (NSString *)_xcodeAppPathFromOldStyleDevToolsPath:(NSString *)devToolsPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;

    // Try the most likely case by far.
    NSString *probableXcodeAppPath = [devToolsPath stringByAppendingPathComponent:@"Applications/Xcode.app"];
    if ([fm fileExistsAtPath:probableXcodeAppPath isDirectory:&isDir] && isDir)
    {
        // If it's called Xcode.app, assume it's Xcode.
        return probableXcodeAppPath;
    }
    
    // No luck with the easy case, so try all items in [devToolsPath]/Applications.
    NSString *applicationsDirPath = [devToolsPath stringByAppendingPathComponent:@"Applications"];
    NSError *error = nil;
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:applicationsDirPath error:&error];

    if (!dirContents)
    {
        DIGSLogInfo(@"Couldn't get contents of '%@'. %@", applicationsDirPath, error);
        return nil;
    }

    for (NSString *dirItem in dirContents)
    {
        NSString *maybeAppPath = [applicationsDirPath stringByAppendingPathComponent:dirItem];
        NSString *maybeXcodeBinaryPath = [maybeAppPath stringByAppendingPathComponent:@"Contents/MacOS/Xcode"];

        if ([fm fileExistsAtPath:maybeXcodeBinaryPath])
        {
            return maybeAppPath;
        }
    }

    // If we got this far, we couldn't find an Xcode app.
    return nil;
}

@end
