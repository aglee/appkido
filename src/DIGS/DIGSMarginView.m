/*
 * DIGSMarginView.m
 *
 * Created by Andy Lee on Sat Sep 21 2002.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "DIGSMarginView.h"


#pragma mark -
#pragma mark Forward declarations of private methods

@interface DIGSMarginView (Private)
- (void)_figureOutWhichSubviewIsWhich;
- (void)_doTheHardCalc:(NSRect *)frameOnePtr :(NSRect *)frameTwoPtr;
- (void)_doTheEasyCalc:(NSRect *)framePtr;
@end


@implementation DIGSMarginView


#pragma mark -
#pragma mark Init/awake/dealloc

- (void)awakeFromNib
{
    _initialSize = [self bounds].size;

    // Set remaining ivars.
    [self _figureOutWhichSubviewIsWhich];
}


#pragma mark -
#pragma mark NSView methods

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
    NSRect newFrameOne = _initialFrameOne;
    NSRect newFrameTwo = _initialFrameTwo;

    // Calculate the subviews' new sizes in the direction of their adjacency.
    [self _doTheHardCalc:&newFrameOne :&newFrameTwo];

    // Calculate the subviews' new sizes in the opposite direction.
    [self _doTheEasyCalc:&newFrameOne];
    [self _doTheEasyCalc:&newFrameTwo];

    // Update the subviews' frames.
    [_viewOne setFrame:newFrameOne];
    [_viewTwo setFrame:newFrameTwo];
}

@end



#pragma mark -
#pragma mark Private methods

@implementation DIGSMarginView (Private)

/*
 * Called by awakeFromNib.
 *
 * Sets _viewOne, _viewTwo, _initialFrameOne, _initialFrameTwo,
 * _isViewOneFlexible, and _isViewTwoFlexible.
 *
 * If the views are top-and-bottom, _viewOne will be the *bottom* one.  If
 * the views are side-by-side, _viewOne will be the *left* one.
 */
- (void)_figureOutWhichSubviewIsWhich
{
    NSArray *subs = [self subviews];
    NSView *subviewA;
    NSView *subviewB;
    NSRect frameA;
    NSRect frameB;

    if ([subs count] != 2)
    {
        // FIXME [agl] also make sure both views completely contained
        // FIXME [agl] also make sure views don't overlap
        [NSException
            raise:@"a DIGSMarginView must have exactly 2 subviews"
            format:@"a DIGSMarginView must have exactly 2 subviews"];
        return;
    }

    subviewA = [subs objectAtIndex:0];
    subviewB = [subs objectAtIndex:1];
    frameA = [subviewA frame];
    frameB = [subviewB frame];

    // Set _isSideBySide, _viewOne, and _viewTwo.
    if (NSMaxY(frameA) <= NSMinY(frameB))
    {
        _isSideBySide = NO;
        _viewOne = subviewA;
        _viewTwo = subviewB;
    }
    else if (NSMaxY(frameB) <= NSMinY(frameA))
    {
        _isSideBySide = NO;
        _viewOne = subviewB;
        _viewTwo = subviewA;
    }
    else if (NSMaxX(frameA) <= NSMinX(frameB))
    {
        _isSideBySide = YES;
        _viewOne = subviewA;
        _viewTwo = subviewB;
    }
    else if (NSMaxX(frameB) <= NSMinX(frameA))
    {
        _isSideBySide = YES;
        _viewOne = subviewB;
        _viewTwo = subviewA;
    }

    // Set _initialFrameOne and _initialFrameTwo.
    _initialFrameOne = [_viewOne frame];
    _initialFrameTwo = [_viewTwo frame];

    // Set _isViewOneFlexible and _isViewTwoFlexible.
    if (_isSideBySide)
    {
        _isViewOneFlexible =
            ([_viewOne autoresizingMask] & NSViewWidthSizable) != 0;
        _isViewTwoFlexible =
            ([_viewTwo autoresizingMask] & NSViewWidthSizable) != 0;
    }
    else
    {
        _isViewOneFlexible =
            ([_viewOne autoresizingMask] & NSViewHeightSizable) != 0;
        _isViewTwoFlexible =
            ([_viewTwo autoresizingMask] & NSViewHeightSizable) != 0;
    }
}

/*
 * Called by resizeSubviewsWithOldSize:.
 */
- (void)_doTheHardCalc:(NSRect *)frameOnePtr :(NSRect *)frameTwoPtr
{
    NSSize newSize = [self bounds].size;
    float initialTotalLength =
        _isSideBySide
        ? _initialSize.width
        : _initialSize.height;
    float newTotalLength =
        _isSideBySide
        ? newSize.width
        : newSize.height;
    float *coordOnePtr =
        _isSideBySide
        ? &(frameOnePtr->origin.x)
        : &(frameOnePtr->origin.y);
    float *lengthOnePtr =
        _isSideBySide
        ? &(frameOnePtr->size.width)
        : &(frameOnePtr->size.height);
    float *coordTwoPtr =
        _isSideBySide
        ? &(frameTwoPtr->origin.x)
        : &(frameTwoPtr->origin.y);
    float *lengthTwoPtr =
        _isSideBySide
        ? &(frameTwoPtr->size.width)
        : &(frameTwoPtr->size.height);
    float totalMargin = initialTotalLength - *lengthOnePtr - *lengthTwoPtr;
    float marginOne = *coordOnePtr;
    float marginTwo = *coordTwoPtr - *coordOnePtr - *lengthOnePtr;
    float availableLength = newTotalLength - totalMargin;

    // Is there room for any view portions at all?
    if (availableLength <= 0.0)
    {
        *lengthOnePtr = 0.0;
        *lengthTwoPtr = 0.0;
    }
    else if (!_isViewOneFlexible)
    {
        // Is there room for view one to be its preferred minimum size?
        if (availableLength > *lengthOnePtr)
        {
            // Yes -- adjust view two as needed.
            *lengthTwoPtr = availableLength - *lengthOnePtr;
        }
        else
        {
            // No -- zero out view two and give view one as much length
            // as we can.
            *lengthTwoPtr = 0.0;
            *lengthOnePtr = availableLength;
        }
    }
    else if (!_isViewTwoFlexible)
    {
        // Is there room for view two to be its preferred minimum size?
        if (availableLength > *lengthTwoPtr)
        {
            // Yes -- adjust view one as needed.
            *lengthOnePtr = availableLength - *lengthTwoPtr;
        }
        else
        {
            // No -- zero out view one and give view two as much length
            // as we can.
            *lengthOnePtr = 0.0;
            *lengthTwoPtr = availableLength;
        }
    }
    else
    {
        // If we got this far, we have two flexible views.  Scale them
        // both to fit availableLength.
        *lengthOnePtr *=
            availableLength / (initialTotalLength - totalMargin);
        *lengthTwoPtr = availableLength - *lengthOnePtr;
    }

    // Slide view two as necessary so as to keep its distance from
    // view one.
    *coordTwoPtr = marginOne + *lengthOnePtr + marginTwo;
}

/*
 * Called by resizeSubviewsWithOldSize:.
 *
 * These calculations are done in the opposite axis from the ones
 * in _doTheHardCalc::.
 */
- (void)_doTheEasyCalc:(NSRect *)framePtr
{
    NSSize newSize = [self bounds].size;
    float initialTotalLength =
        _isSideBySide
        ? _initialSize.height
        : _initialSize.width;
    float newTotalLength =
        _isSideBySide
        ? newSize.height
        : newSize.width;
    float *lengthPtr =
        _isSideBySide
        ? &(framePtr->size.height)
        : &(framePtr->size.width);
    float totalMargin = initialTotalLength - *lengthPtr;
    float availableLength = newTotalLength - totalMargin;

    if (availableLength <= 0.0)
    {
        *lengthPtr = 0.0;
    }
    else
    {
        *lengthPtr = availableLength;
    }
}

@end
