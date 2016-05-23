//
//  AKBorderHidingView.h
//  AppKiDo
//
//  Created by Andy Lee on 3/11/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 * Expects to have exactly one subview, which is sized and positioned so that
 * its edges lie one pixel outside the AKBorderHidingView. Assumes Auto Layout
 * is not being used.
 *
 * I created this class because NSBrowser doesn't have a built-in way to turn
 * off its border like some other views do. By putting the NSBrowser inside an
 * AKBorderHidingView, we achieve the same effect.
 */
@interface AKBorderHidingView : NSView

#pragma mark - Init/awake/dealloc

/*!
 * Sets the inner view's frame and autoresizing mask, superseding whatever those
 * were set to in the nib.
 *
 * One advantage of setting the frame programmatically is that you don't have to
 * be precise when laying out the inner view in IB. In the nib you can have a
 * generous margin around the inner view, making it easier to select and
 * manipulate.
 */
- (void)awakeFromNib;

@end
