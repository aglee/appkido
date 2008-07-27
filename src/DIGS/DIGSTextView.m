/*
 * DIGSTextView.m
 *
 * Created by Andy Lee on Mon May 19 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "DIGSTextView.h"

#import <DIGSLog.h>

//-------------------------------------------------------------------------
// Forward declarations of private methods
//-------------------------------------------------------------------------

@interface DIGSTextView (Private)
- (void)_initLinkCursor;
- (void)_setCursorRectsForLinks;
@end


@implementation DIGSTextView

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect]))
    {
        [self _initLinkCursor];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super initWithCoder:decoder]))
    {
        [self _initLinkCursor];
    }

    return self;
}

- (void)dealloc
{
    [_linkCursor release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (NSString *)linkCursorImageName
{
    return @"handcursor.tiff";
}

- (NSPoint)linkCursorHotSpot
{
    return NSMakePoint(6, 0);
}

//-------------------------------------------------------------------------
// NSTextView methods
//-------------------------------------------------------------------------

- (void)resetCursorRects
{
    [super resetCursorRects]; // discards old cursor rects
    [self _setCursorRectsForLinks];
}

@end


//-------------------------------------------------------------------------
// Private methods
//-------------------------------------------------------------------------

@implementation DIGSTextView (Private)

- (void)_initLinkCursor
{
    if (_linkCursor == nil)
    {
        NSImage *image = [NSImage imageNamed:[self linkCursorImageName]];
        NSPoint hotSpot = [self linkCursorHotSpot];

        if (image != nil)
        {
            _linkCursor =
                [[NSCursor alloc] initWithImage:image hotSpot:hotSpot];
        }
        else
        {
            DIGSLogWarning(
                @"failed to load image named %@ for use as the link cursor",
                [self linkCursorImageName]);
            _linkCursor = [[NSCursor arrowCursor] retain];
        }
    }
}

- (void)_setCursorRectsForLinks
{
     NSTextStorage *attrString = [self textStorage];
     unsigned loc = 0;
     unsigned end = [attrString length];

     while (loc < end)
     {
         NSRange linkRange;
         id attributeValue =
            [attrString attribute:NSLinkAttributeName
                atIndex:loc
                longestEffectiveRange:&linkRange
                inRange:NSMakeRange(loc, end - loc)];

         if (attributeValue != nil)
         {
            NSRect linkRect =
                [[self layoutManager]
                    boundingRectForGlyphRange:linkRange
                    inTextContainer:[self textContainer]];

            [self addCursorRect:linkRect cursor:_linkCursor];
            loc = NSMaxRange(linkRange);
         }
         else
         {
            loc++;
         }
     }
}

@end
