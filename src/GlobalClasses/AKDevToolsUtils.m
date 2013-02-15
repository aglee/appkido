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

@end
