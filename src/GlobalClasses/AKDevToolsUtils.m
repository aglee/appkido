/*
 *  AKDevToolsUtils.m
 *
 *  Created by Andy Lee on 1/25/08.
 *  Copyright 2008 Andy Lee. All rights reserved.
 */

#import "AKDevToolsUtils.h"

#import "AKTextUtils.h"
#import "AKDocSetIndex.h"

@implementation AKDevToolsUtils


#pragma mark -
#pragma mark Finding the user's Dev Tools

// Can't use NSTask because stdout and/or stderr gets screwed up and
// subsequent NSLogs don't print anything, perhaps because xcode-select
// is a shell script?  Tried the popen approach, that didn't work either --
// got empty string as result *except* when I stepped through with debugger.
// Looked at the xcode-select script and all it seems to do is look for a
// little file called xcode_dir_path, so ended up with simplest
// implementation of all.
+ (NSString *)devToolsPathAccordingToXcodeSelect
{
    NSString *devToolsPath =
        [NSString stringWithContentsOfFile:
            @"/usr/share/xcode-select/xcode_dir_path"];

    if (devToolsPath == nil)
    {
        return nil;
    }
    else
    {
        return [devToolsPath ak_trimWhitespace];
    }
}

@end
