/*
 * DIGSLog.m
 *
 * Created by Andy Lee on Wed Jul 10 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "DIGSLog.h"

static NSInteger s_verbosityLevel = DIGS_VERBOSITY_INFO;

NSInteger DIGSGetVerbosityLevel()
{
	return s_verbosityLevel;
}

void DIGSSetVerbosityLevel(NSInteger level)
{
	s_verbosityLevel = level;
}

