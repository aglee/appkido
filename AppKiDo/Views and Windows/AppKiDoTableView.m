/*
 * AppKiDoTableView.m
 *
 * Created by Andy Lee on Wed May 28 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AppKiDoTableView.h"

#import "AKPrefUtils.h"
#import "AKTabChain.h"
#import "AKWindowController.h"

#import "NSView+AppKiDo.h"

@implementation AppKiDoTableView

#pragma mark - Preferences

- (void)applyListFontPrefs
{
    NSString *fontName = [AKPrefUtils stringValueForPref:AKListFontNamePrefName];
    NSInteger fontSize = [AKPrefUtils intValueForPref:AKListFontSizePrefName];
    NSFont *font = [NSFont fontWithName:fontName size:fontSize];
    NSLayoutManager * lm = [[NSLayoutManager alloc] init];
 	NSInteger newRowHeight = round([lm defaultLineHeightForFont:font] + 1.0); 

    [self.tableColumns[0].dataCell setFont:font];
    self.rowHeight = newRowHeight;
    [self setNeedsDisplay:YES];
}

#pragma mark - NSView methods

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

#pragma mark - NSResponder methods

// NSTableView doesn't trigger actions when you navigate with the keyboard.
// This override does.
- (void)keyDown:(NSEvent *)theEvent
{
    NSString *eventChars = theEvent.characters;

    if ([eventChars isEqualToString:@"\n"]
        || [eventChars isEqualToString:@"\r"])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.doubleAction withObject:self];
#pragma clang diagnostic pop
    }
    else
    {
        NSInteger oldSelectedRow = self.selectedRow;

        [super keyDown:theEvent];

        if (self.selectedRow != oldSelectedRow)
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.target performSelector:self.action withObject:self];
#pragma clang diagnostic pop
        }
    }
}

// This is a total KLUDGE. Allows left and right arrow keys to move between the
// subtopic list and the doc list.
- (void)moveLeft:(id)sender
{
    if ([self.window.delegate isKindOfClass:[AKWindowController class]])
    {
        NSSplitView *splitView = [self ak_enclosingViewOfClass:[NSSplitView class]];

        if ([self isDescendantOf:splitView.subviews[1]])
        {
            (void)[AKTabChain stepThroughTabChainInWindow:self.window forward:NO];
        }
    }
}

// This is a total KLUDGE. Allows left and right arrow keys to move between the
// subtopic list and the doc list.
- (void)moveRight:(id)sender
{
    if ([self.window.delegate isKindOfClass:[AKWindowController class]])
    {
        NSSplitView *splitView = [self ak_enclosingViewOfClass:[NSSplitView class]];

        if ([self isDescendantOf:splitView.subviews[0]])
        {
            (void)[AKTabChain stepThroughTabChainInWindow:self.window forward:YES];
        }
    }
}

@end
