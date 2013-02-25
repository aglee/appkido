/*
 * AKMultiRadioView.h
 *
 * Created by Andy Lee on Sun May 22 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import <AppKit/AppKit.h>

/*!
 * @class       AKMultiRadioView
 * @abstract    Manages multiple radio matrixes ("co-matrixes") so that
 *              they behave together like one big radio matrix.
 * @discussion  The co-matrixes must be radio style and allow empty
 *              selection.  Cell tags must be unique across all
 *              co-matrixes.
 *
 *              In IB, create a setup matrix that will be used by
 *              -awakeFromNib and then discarded.  The setup matrix has
 *              one cell per co-matrix.  Each cell of the setup matrix
 *              points to a co-matrix via its target outlet (select any
 *              action; it is ignored).  The target and action of the
 *              setup matrix itself (as opposed to its cells) are what
 *              the target and action of the co-matrixes would have been
 *              if there were only one.
 */
@interface AKMultiRadioView : NSView
{
@private
    NSMatrix *_selectedRadioMatrix;
    SEL _radioAction;  // gets set in -awakeFromNib
    id _radioTarget;  // gets set in -awakeFromNib
}

#pragma mark -
#pragma mark Getters and setters

- (NSInteger)selectedTag;
- (BOOL)selectCellWithTag:(NSInteger)tag;

#pragma mark -
#pragma mark Action methods

- (IBAction)doRadioAction:(id)sender;

@end
