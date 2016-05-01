//
//  QuietLog.m
//  AppKiDo
//
//  Created by Andy Lee on 4/4/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "QuietLog.h"

// NSLog() writes out entirely too much stuff.  Most of the time I'm
// not interested in the program name, process ID, and current time
// down to the subsecond level.
// This takes an NSString with printf-style format, and outputs it.
// regular old printf can't be used instead because it doesn't
// support the '%@' format option.

void QuietLog (NSString *format, ...) {
    va_list argList;
    va_start (argList, format);
    NSString *message = [[NSString alloc] initWithFormat: format
                                                arguments: argList];
    fprintf (stderr, "%s\n", message.UTF8String);
    va_end  (argList);
}
