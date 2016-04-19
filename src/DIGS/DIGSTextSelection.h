/*
 * DIGSTextSelection.h
 *
 * Created by Andy Lee on Mon Jun 23 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import "AKPrefDictionary.h"

//TODO: Currently not used and not tested in a very long time.  Remove?  Revive?

/*!
 * Remembers the selection range and scroll position of an NSTextView. To take a
 * snapshot of an NSTextView, use -takeSelectionFromTextView:.  To apply a
 * remembered display state to an NSTextView, use applySelectionToTextView:.
 */
@interface DIGSTextSelection : NSObject <NSCoding>
{
@private
    // The text view's -visibleRect at the moment of the snapshot.  Used
    // when resetting a text view's scroll position.  If the text view's
    // size is different from the size of _visibleRect, _visibleRect is
    // ignored and _visibleCharsRange is used instead for resetting the
    // scroll position.
    NSRect _visibleRect;

    // The range of characters that was visible in the text view at the
    // moment of the snapshot.
    NSRange _visibleCharsRange;

    // The range of characters that was selected at the moment of the
    // snapshot.
    NSRange _selectedCharsRange;

    // The text view's -typingAttributes.  If we didn't remember this, then
    // when we later applied ourselves to a text view, we would get stuck
    // with typing attributes inherited from the previous state of the text
    // view, such as what font it was poised to use for typing.
    NSDictionary *_typingAttributes;
}

@property (nonatomic, assign) NSRect visibleRect;
@property (nonatomic, assign) NSRange visibleCharsRange;
@property (nonatomic, assign) NSRange selectedCharsRange;
@property (nonatomic, copy) NSDictionary *typingAttributes;

#pragma mark -
#pragma mark Interacting with text views

/*! Takes a snapshot of the text view's selection range and scroll position. */
- (void)takeSelectionFromTextView:(NSTextView *)textView;

/*!
 * Applies the receiver's info to the given text view.  You might want to send
 * the text view a sizeToFit message just before calling this.
 */
- (void)applySelectionToTextView:(NSTextView *)textView;

@end
