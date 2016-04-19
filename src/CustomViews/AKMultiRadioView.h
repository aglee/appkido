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
 *
 * HOW TO USE
 * ----------
 * In the nib, create an AKMultiRadioView and drop one or more NSMatrix
 * instances into it as subviews. Make the matrixes all of type radio and give
 * their cells unique tags. Make the AKMultiRadioView the target of all the
 * NSMatrix instances (not the cells, but the matrix controls), with
 * doRadioAction: as the action.
 * 
 * Connect the AKMultiRadioView's delegate, either in IB or in code. In the
 * delegate, implement multiRadioViewDidMakeSelection: to take some action based
 * on the selectedTag of the sender.
 */
@interface AKMultiRadioView : NSView
{
@private
    id <AKMultiRadioViewDelegate> __unsafe_unretained _delegate;
}

@property (nonatomic, unsafe_unretained) IBOutlet id <AKMultiRadioViewDelegate> delegate;

#pragma mark -
#pragma mark Getters and setters

/*! Returns -1 if no submatrix has a selected cell. */
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger selectedTag;
- (BOOL)selectCellWithTag:(NSInteger)tag;

#pragma mark -
#pragma mark Action methods

/*! Messages the delegate. */
- (IBAction)doRadioAction:(id)sender;

@end
