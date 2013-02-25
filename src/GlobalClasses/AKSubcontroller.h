/*
 * AKSubcontroller.h
 *
 * Created by Andy Lee on Sat May 24 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>

/*!
 * @class       AKSubcontroller
 * @abstract    Base class for controllers that are subordinate to an
 *              "owning" controller.
 * @discussion  An AKSubcontroller handles some part of the broader
 *              responsibility of an "owning" controller object such as
 *              the application controller or a window controller.
 *
 *              AKSubcontrollers respond to several messages that are
 *              forwarded to them from the owning controller.
 */
@interface AKSubcontroller : NSObject

#pragma mark -
#pragma mark Init/awake/dealloc

/*!
 * @method      doAwakeFromNib
 * @discussion  Initializes me just after I've been loaded from a nib
 *              file.  Subclasses should implement either this or
 *              -awakeFromNib, or neither, but not both.  If I implement
 *              -doAwakeFromNib, my owning controller should send me a
 *              -doAwakeFromNib message in its own awake method.  The
 *              owning controller might want to do this if it cares about
 *              the order in which it subcontrollers awake.  Relying on
 *              -awakeFromNib would not guarantee that order.
 *
 *              The default implementation does nothing.
 */
- (void)doAwakeFromNib;

#pragma mark -
#pragma mark User preferences

/*!
 * @method      applyUserPreferences
 * @discussion  Applies the user's preference settings to the objects I
 *              control.  The default implementation does nothing.
 */
- (void)applyUserPreferences;

#pragma mark -
#pragma mark UI item validation

/*!
 * @method      validateItem:
 * @discussion  Returns true if the specified UI item should be enabled.
 *              Contains shared logic for validating both menu items and
 *              toolbar items.  The default implementation returns NO.
 * @param       anItem
 *                  Either an NSMenuItem or an NSToolbarItem.
 */
- (BOOL)validateItem:(id)anItem;

@end
