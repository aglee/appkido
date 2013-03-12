/*
 * AKTableView.m
 *
 * Created by Andy Lee on Wed May 28 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTableView.h"

#import "AKPrefUtils.h"

@implementation AKTableView

#pragma mark -
#pragma mark Preferences

- (void)applyListFontPrefs
{
    NSString *fontName = [AKPrefUtils stringValueForPref:AKListFontNamePrefName];
    NSInteger fontSize = [AKPrefUtils intValueForPref:AKListFontSizePrefName];
    NSFont *font = [NSFont fontWithName:fontName size:fontSize];
    NSLayoutManager * lm = [[[NSLayoutManager alloc] init] autorelease];
 	NSInteger newRowHeight = round([lm defaultLineHeightForFont:font] + 1.0); 

    [[[[self tableColumns] objectAtIndex:0] dataCell] setFont:font];
    [self setRowHeight:newRowHeight];
    [self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark NSView methods

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

@end
