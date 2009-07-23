/*
 * DIGSFindBuffer.h
 *
 * Created by Andy Lee on Sat May 17 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

/*!
 * @class       DIGSFindBuffer
 * @abstract    Holds your application's search string.
 * @discussion  DIGSFindBuffer is a singleton class that holds the string
 *              your application should use for text searches.  This
 *              string is called the "find buffer."  When your application
 *              sets the find buffer, via -setFindString:, DIGSFindBuffer
 *              puts it into the find-pasteboard so that other applications
 *              will pick it up.  Conversely, when other applications write
 *              to the find-pasteboard, DIGSFindBuffer updates its find
 *              buffer accordingly the next time your application gets an
 *              appDidActivate notification.
 *
 *              Objects can register interest in the find buffer via
 *              -addListener:withSelector:.  The DIGSFindBuffer messages
 *              its listeners whenever it discovers the find-pasteboard
 *              has changed.  Listener objects can use -findString to find
 *              out what the new find buffer is and react accordingly.  An
 *              example of a listener object might be the controller for
 *              your application's Find panel.
 *
 *              Note that DIGSFindBuffer does not retain its listeners.
 *              Listeners must unregister interest, via -removeListener:,
 *              before being deallocated -- i.e., in their -dealloc
 *              methods.  This is the same pattern used by
 *              NSNotificationCenters, which do not retain their observers.
 */
@interface DIGSFindBuffer : NSObject
{
@private
    // The current find string.
    NSString *_findString;

    // Elements are NSValues containing pointers to my listener objects.
    // The pointers are wrapped in NSValues so the listener objects
    // themselves do not get retained when they are added.
    NSMutableArray *_listenerPointers;

    // Elements are NSValues containing selectors that specify the actions
    // my listeners will take when I notify them.
    NSMutableArray *_listenerActions;
}


#pragma mark -
#pragma mark Factory methods

/*!
 * @method      sharedInstance
 * @discussion  Returns the singleton instance of this class.
 */
+ (DIGSFindBuffer *)sharedInstance;


#pragma mark -
#pragma mark Getters and setters

/*!
 * @method      findString
 * @discussion  Returns the contents of the find buffer.
 */
- (NSString *)findString;

/*!
 * @method      setFindString:
 * @discussion  Sets the find buffer, updates the system find-pasteboard,
 *              and notifies my listeners of the change.
 */
- (void)setFindString:(NSString *)string;


#pragma mark -
#pragma mark Managing listeners

/*!
 * @method      addListener:withSelector:
 * @discussion  Adds listenerObject to my collection of listeners, if it's
 *              not already there.
 * @param       listenerObject
 *                  An object that implements the method specified by
 *                  handlerSelector.
 * @param       handlerSelector
 *                  Must specify a method that takes a single argument
 *                  that is an instance of DIGSFindBuffer.
 */
- (void)addListener:(id)listenerObject withSelector:(SEL)handlerSelector;

/*!
 * @method      removeListener:
 * @discussion  Removes listenerObject from my collection of listeners.
 */
- (void)removeListener:(id)listenerObject;

@end
