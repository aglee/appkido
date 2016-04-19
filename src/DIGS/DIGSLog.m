/*
 * DIGSLog.m
 *
 * Created by Andy Lee on Wed Jul 10 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "DIGSLog.h"

const NSString *DIGSLogVerbosityUserDefault = @"DIGSVerbosity";

static NSInteger g_verbosityLevel = DIGS_VERBOSITY_INFO;

NSInteger DIGSGetVerbosityLevel() { return g_verbosityLevel; }

void DIGSSetVerbosityLevel(NSInteger level) { g_verbosityLevel = level; }

/* Copped from http://www.cocoabuilder.com/archive/message/cocoa/2007/12/13/194858 */
int DIGSPrintf(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    
    NSString *output = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    int result = printf("%s", [output UTF8String]);
    
    return result;
}

int DIGSPrintln(NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    
    NSString *output = [[NSString alloc] initWithFormat:[format stringByAppendingString:@"\n"]
                                               arguments:args];
    va_end(args);
    
    int result = printf("%s", [output UTF8String]);
    
    return result;
}
