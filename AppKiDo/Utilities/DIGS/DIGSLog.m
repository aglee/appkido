/*
 * DIGSLog.m
 *
 * Created by Andy Lee on Wed Jul 10 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "DIGSLog.h"

#pragma mark - QuietLog

void QuietLog (NSString *format, ...)
{
	va_list argList;
	va_start (argList, format);
	{{
		NSString *message = [[NSString alloc] initWithFormat:format arguments:argList];
		fprintf (stderr, "%s\n", message.UTF8String);
	}}
	va_end  (argList);
}

#pragma mark - Indented output

void DIGSPrintTabIndented(NSInteger indentLevel, NSString *format, ...)
{
	va_list argList;
	va_start(argList, format);
	{{
		NSString *indent = [@"" stringByPaddingToLength:indentLevel
											 withString:@"\t"
										startingAtIndex:0];
		NSString *message = [[NSString alloc] initWithFormat:format arguments:argList];
		fprintf(stderr, "%s%s\n", indent.UTF8String, message.UTF8String);
	}}
	va_end(argList);
}

#pragma mark - DIGSLog

static NSInteger s_verbosityLevel = DIGS_VERBOSITY_INFO;

NSInteger DIGSGetVerbosityLevel()
{
	return s_verbosityLevel;
}

void DIGSSetVerbosityLevel(NSInteger level)
{
	s_verbosityLevel = level;
}

