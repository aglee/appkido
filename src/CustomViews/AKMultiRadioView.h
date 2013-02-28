/*
 * AKMultiRadioView.h
 *
 * Created by Andy Lee on Sun May 22 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import <AppKit/AppKit.h>
#import "AKMultiRadioViewDelegate.h"

/*!
 * Manages multiple radio-style NSMatrix objects ("submatrixes") so that they
 * they behave together like one big radio matrix.
 *
 * At any given time, the submatrixes are defined as those immediate subviews
 * (i.e., elements of [self subviews]) which:
 *
 *  * are instances of NSMatrix,
 *  * have NSRadioModeMatrix as their -mode,
 *  * return true for -allowsEmptySelection, and
 *  * have self as their target with doRadioAction: as the action.
 *
 * Cell tags must be unique across all submatrixes. It's up to you to make this
 * so.
 */
@interface AKMultiRadioView : NSView
{
@private
    id <AKMultiRadioViewDelegate> _delegate;
}

@property (nonatomic, assign) IBOutlet id <AKMultiRadioViewDelegate> delegate;

#pragma mark -
#pragma mark Getters and setters

/*! Returns -1 if no submatrix has a selected cell. */
- (NSInteger)selectedTag;
- (BOOL)selectCellWithTag:(NSInteger)tag;

#pragma mark -
#pragma mark Action methods

/*! Messages the delegate. */
- (IBAction)doRadioAction:(id)sender;

@end
