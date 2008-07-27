/*
 * DIGSTextView.h
 *
 * Created by Andy Lee on Mon May 19 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

/*!
 * @class       DIGSTextView
 * @abstract    A text view that puts a special cursor over links.
 * @discussion  One way to use this class is to do the following in main(),
 *              before the call to NSApplicationMain():
<pre>
&nbsp;   [DIGSTextView poseAsClass:[NSTextView class]];
</pre>
 *              The cursor image is gotten from a resource whose name is
 *              given by -cursorImageName.
 *
 *              Note: the -resetCursorRects logic was copied from
 *              http://cocoa.mamasam.com/COCOADEV/2001/12/2/20937.php.
 */
@interface DIGSTextView : NSTextView
{
@private
    NSCursor *_linkCursor;
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

/*!
 * @method      initWithFrame:
 * @discussion  Loads the cursor image we will use to indicate the cursor
 *              is over a link.  Gets the image from a resource whose name
 *              is given by -cursorImageName.  Gets the hot spot point
 *              from -linkCursorHotSpot.
 */
- (id)initWithFrame:(NSRect)frameRect;

/*!
 * @method      initWithCoder:
 * @discussion  See -initWithFrame:.
 */
- (id)initWithCoder:(NSCoder *)decoder;

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

/*!
 * @method      linkCursorImageName
 * @discussion  Returns the name of the image resource that I should use for
 *              the cursor when it hovers over a link in my displayed text.
 *
 *              Defaults to "handcursor.tiff".
 */
- (NSString *)linkCursorImageName;

/*!
 * @method      linkCursorHotSpot
 * @discussion  Returns the hot spot point that I should use for the cursor
 *              when it hovers over a link in my displayed text.
 *
 *              Defaults to (6, 0).
 */
- (NSPoint)linkCursorHotSpot;

//-------------------------------------------------------------------------
// NSTextView methods
//-------------------------------------------------------------------------

/*!
 * @method      resetCursorRects
 * @discussion  Adds cursor rects that identify the links in my text as
 *              links.
 */
- (void)resetCursorRects;

@end
