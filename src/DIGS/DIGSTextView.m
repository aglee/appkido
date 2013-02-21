/*
 * DIGSTextView.m
 *
 * Created by Andy Lee on Mon May 19 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "DIGSTextView.h"

#import "DIGSLog.h"


#pragma mark -
#pragma mark Forward declarations of private methods

@interface DIGSTextView (Private)
- (void)_initLinkCursor;
- (void)_setCursorRectsForLinks;
@end


@implementation DIGSTextView


#pragma mark -
#pragma mark Init/awake/dealloc

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



#pragma mark -
#pragma mark Getters and setters

- (NSString *)linkCursorImageName
{
    return @"handcursor.tiff";
}

- (NSPoint)linkCursorHotSpot
{
    return NSMakePoint(6, 0);
}


#pragma mark -
#pragma mark NSTextView methods

- (void)resetCursorRects
{
    [super resetCursorRects]; // discards old cursor rects
    [self _setCursorRectsForLinks];
}

@end



#pragma mark -
#pragma mark Private methods

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
            _linkCursor = [NSCursor arrowCursor];
        }
    }
}

- (void)_setCursorRectsForLinks
{
     NSTextStorage *attrString = [self textStorage];
     NSUInteger loc = 0;
     NSUInteger end = [attrString length];

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
