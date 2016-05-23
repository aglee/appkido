/*
 * DIGSMatchingBackgroundView.h
 *
 * Created by Andy Lee on Sat Sep 21 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <AppKit/AppKit.h>

/*!
 * @class       DIGSMatchingBackgroundView
 * @abstract    Matches the background color of some other view
 * @discussion  A DIGSMatchingBackgroundView fills itself with the
 *              background color of some other view (not necessarily a
 *              subview).  The other view must have a -backgroundColor
 *              method that returns an NSColor.
 */
@interface DIGSMatchingBackgroundView : NSView
{
@private
    IBOutlet NSView *_viewToMatch;
}

#pragma mark - NSView methods

- (void)drawRect:(NSRect)aRect;

@end
