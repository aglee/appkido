/*
 *  AKDevToolsUtils.m
 *
 *  Created by Andy Lee on 1/25/08.
 *  Copyright 2008 Andy Lee. All rights reserved.
 */

#import "AKDevToolsUtils.h"

#import "ALSimpleTask.h"
#import "AKTextUtils.h"
#import "AKDocSetIndex.h"

@implementation AKDevToolsUtils


#pragma mark -
#pragma mark Finding the user's Dev Tools

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
+ (NSString *)devToolsPathAccordingToXcodeSelect
{
    NSString *devToolsPath = nil;

    // The reason I use bash -l to run xcode-select is that it's possible for
    // the user to specify a path in the DEVELOPER_DIR environment variable that
    // supersedes what xcode-select would otherwise return. If for some reason
    // they've set that up in their bash config, I assume that's the path they'd
    // really want us to use as the default.
	ALSimpleTask *tw = [[ALSimpleTask alloc] initWithCommandPath:@"/bin/bash"
													   arguments:(@[
																  @"-l",
																  @"-c",
																  @"echo -n `/usr/bin/xcode-select -print-path`"
																  ])];
	if (![tw runTask])
	{
		NSLog(@"Failed to launch xcode-select. Reason: %@.", [tw outputString]);
	}
    else if ([tw exitStatus] != 0)
    {
		NSLog(@"xcode-select failed with exit status %d.", [tw exitStatus]);
    }
    else
    {
        devToolsPath = [[tw outputString] ak_trimWhitespace];
    }

    if ([devToolsPath length] == 0)
    {
        // We got nothing from xcode-select, so return a hard-coded default.
        return @"/Applications/Xcode.app/Contents/Developer";
    }
    else if ([[devToolsPath pathExtension] isEqualToString:@"app"])
    {
        // We're looking at a path to an Xcode app bundle.
        NSString *devToolsPathWithinXcode = [devToolsPath stringByAppendingPathComponent:@"Contents/Developer"];

        if ([[NSFileManager defaultManager] fileExistsAtPath:devToolsPathWithinXcode])
        {
            // It looks like we're looking at a new-style Xcode installation
            // with everything living in the Xcode.app bundle. For example, if
            // xcode-select returned /Applications/Xcode.app, we want to return
            // /Applications/Xcode.app/Contents/Developer.
            //
            // Note that "xcode-select -switch" adds "Contents/Developer" to the
            // path for you, but it is possible that the user set DEVELOPER_DIR
            // to something like /Applications/Xcode.app.
            return devToolsPathWithinXcode;
        }
        else
        {
            NSString *pathToDirContainingXcode = [devToolsPath stringByDeletingLastPathComponent];
            NSString *nameOfDirContainingXcode = [pathToDirContainingXcode lastPathComponent];
            
            if ([nameOfDirContainingXcode isEqualToString:@"Applications"])
            {
                // Assume we're looking at an old-style Dev Tools installation, the
                // kind that used to be rooted at /Developer, with Xcode being at
                // /Developer/Applications/Xcode.app. We return the directory two
                // levels up. In this example, that would be /Developer.
                return [pathToDirContainingXcode stringByDeletingLastPathComponent];
            }
        }
    }

    // In the absence of anything to indicate otherwise, return exactly what
    // xcode-select returned.
    return devToolsPath;
}

@end
