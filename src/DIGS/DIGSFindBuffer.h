/*
 * DIGSFindBuffer.h
 *
 * Created by Andy Lee on Sat May 17 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import "DIGSFindBufferDelegate.h"

// [agl] Logic is flawed when you add/remove the same delegate object multiply.

/*!
 * Singleton class that holds the string your application should use for text
 * searches.
 *
 * When your application calls -setFindString:, DIGSFindBuffer puts the new
 * find string into the system-wide find-pasteboard so that other applications
 * will pick it up. Conversely, when other applications write to the
 * find-pasteboard, DIGSFindBuffer picks up the new find string the next time
 * your application gets an appDidActivate notification.
 *
 * A DIGSFindBuffer can have any number of delegates. It messages the delegates
 * whenever the find string changes. There is no guaranteed order in which the
 * delegates are messaged. As in the usual single-delegate pattern, delegates
 * are weak references and must be unregistered before being deallocated to
 * avoid dangling pointers.
 */
@interface DIGSFindBuffer : NSObject
{
@private
    // The current find string.
    NSString *_findString;

    // NSValues containing unretained pointers to the delegates.
    // [agl] Could maybe implement this as a bag to allow nested calls to add/removeDelegate.
    NSMutableArray *_delegatePointerValues;
}

/*!
 * The setter sets the find buffer, updates the system find-pasteboard, and
 * notifies delegates of the change.
 */
@property (nonatomic, copy) NSString *findString;

#pragma mark -
#pragma mark Factory methods

+ (DIGSFindBuffer *)sharedInstance;

#pragma mark -
#pragma mark Delegates

/*! Does nothing if the object is already among our delegates. */
- (void)addDelegate:(id <DIGSFindBufferDelegate>)delegate;

- (void)removeDelegate:(id <DIGSFindBufferDelegate>)delegate;

@end
