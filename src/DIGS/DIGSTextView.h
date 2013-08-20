/*
 * DIGSTextView.h
 *
 * Created by Andy Lee on Mon May 19 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

/*!
 * Shows a special cursor when the mouse hovers over links. The cursor image
 * comes from a resource whose name is given by -cursorImageName.
 */
@interface DIGSTextView : NSTextView
{
@private
    NSCursor *_linkCursor;
}

#pragma mark -
#pragma mark Getters and setters

/*!
 * Returns the name of the image resource that should be used for the cursor
 * when it hovers over a link. Defaults to "handcursor.tiff".
 */
- (NSString *)linkCursorImageName;

/*!
 * Returns the hot spot point that should be used when the cursor hovers over a
 * link in my displayed text. Defaults to (6, 0).
 */
- (NSPoint)linkCursorHotSpot;

@end
