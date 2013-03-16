/*
 * AKWindow.m
 *
 * Created by Andy Lee on Wed Apr 28 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKWindow.h"

@implementation AKWindow

#pragma mark -
#pragma mark NSWindow methods

// As suggested by Gerriet Denkmann.  Protects against crashing due to nil.
- (void)setTitle:(NSString *)aString
{
	if (aString == nil)
	{
		aString = @"*** nil ***";
	}

	[super setTitle:aString];
}

@end
