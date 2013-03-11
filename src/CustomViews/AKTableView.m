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
#pragma mark NSResponder methods

// NSTableView doesn't trigger actions when you navigate with the keyboard.
// This override does.
- (void)keyDown:(NSEvent *)theEvent
{
    NSString *eventChars = [theEvent characters];

    if ([eventChars isEqualToString:@"\n"]
        || [eventChars isEqualToString:@"\r"])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [[self target] performSelector:[self doubleAction] withObject:self];
#pragma clang diagnostic pop
    }
    else
    {
        NSInteger oldSelectedRow = [self selectedRow];

        [super keyDown:theEvent];

        if ([self selectedRow] != oldSelectedRow)
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [[self target] performSelector:[self action] withObject:self];
#pragma clang diagnostic pop
        }
    }
}

// Allow the user to use left and right arrow keys to move between the subtopic
// list and the doc list.
- (void)moveLeft:(id)sender
{
    if ([[self previousKeyView] isKindOfClass:[AKTableView class]])
    {
        [[self window] makeFirstResponder:[self previousKeyView]];
    }
}

// Allow the user to use left and right arrow keys to move between the subtopic
// list and the doc list.
- (void)moveRight:(id)sender
{
    if ([[self nextKeyView] isKindOfClass:[AKTableView class]])
    {
        [[self window] makeFirstResponder:[self nextKeyView]];
    }
}

#pragma mark -
#pragma mark NSView methods

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

@end
