/*
 * DIGSWindow.m
 *
 * Created by Andy Lee on Wed Apr 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKWindow.h"
#import "DIGSLog.h"

@implementation AKWindow

// For debugging leaking and over-releasing of NSWindows.
- (void)dealloc
{
    DIGSLogDebug(@"DIGSWindow dealloc [%@]", [self title]);

    [super dealloc];
}

// As suggested by Gerriet Denkmann.  Protects against nil being passed.
- (void)setTitle:(NSString *)aString
{
	if (aString == nil)
	{
		aString = @"*** nil ***";
	}
	
	[super setTitle:aString];
}

@end
