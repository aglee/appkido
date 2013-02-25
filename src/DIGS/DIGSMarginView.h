/*
 * DIGSMarginView.h
 *
 * Created by Andy Lee on Sat Sep 21 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <AppKit/AppKit.h>

// FIXME [agl] NB does not handle replacing of subviews
// FIXME [agl] NB does not handle altering of its own coord system
// FIXME [agl] NB assumes non-flipped coords

/*!
 * @class       DIGSMarginView
 * @abstract    Preserves margins around subviews
 * @discussion  A DIGSMarginView preserves the margins around, and the
 *              separation between, its two subviews.  It must have two
 *              subviews.
 */
@interface DIGSMarginView : NSView
{
@private
    // This is what my size was (in bounds coordinates) just after I was
    // loaded from the nib file.
    NSSize _initialSize;

    // These are my two subviews.  If they are side by side, _viewOne
    // is the one on the left.  If they are one above the other, _viewOne
    // is the bottom one.
    NSView *_viewOne;
    NSView *_viewTwo;

    // These are the frames of my two subviews just after I was loaded
    // from the nib file.
    NSRect _initialFrameOne;
    NSRect _initialFrameTwo;

    // This indicates whether my two subviews are side by side, or one
    // above the other.
    BOOL _isSideBySide;

    // These indicate whether the subview is allowed to resize in the
    // direction indicated by _isSideBySide.
    BOOL _isViewOneFlexible;
    BOOL _isViewTwoFlexible;
}

#pragma mark -
#pragma mark Init/awake/dealloc

/*! Remembers how subviews were laid out when the nib was loaded. */
- (void)awakeFromNib;

#pragma mark -
#pragma mark NSView methods

/*! Preserves the margins around, and the space between, the two subviews. */
- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize;

@end
