/*
 * DIGSFindBuffer.h
 *
 * Created by Andy Lee on Sat May 17 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import "DIGSFindBufferDelegate.h"

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
 *
 * The delegate list is implemented as an NSCountedSet (a bag). Each call to
 * addDelegate: should be balanced with a call to removeDelegate:. Delegate
 * messages are only sent once to a given delegate object, no matter how many
 * times that object was added to the delegate list.
 */
@interface DIGSFindBuffer : NSObject
{
@private
    // The current find string.
    NSString *_findString;

    // NSValues containing unretained pointers to the delegates.
    NSCountedSet *_delegatePointerValues;
}

/*!
 * The setter sets the find buffer, updates the system find-pasteboard, and
 * notifies delegates of the change.
 */
@property (nonatomic, copy) NSString *findString;

#pragma mark - Factory methods

+ (DIGSFindBuffer *)sharedInstance;

#pragma mark - Delegates

/*!
 * The same object can be added as a delegate multiple times. Each call to
 * addDelegate: should be balanced with a call to removeDelegate:.
 */
- (void)addDelegate:(id <DIGSFindBufferDelegate>)delegate;

- (void)removeDelegate:(id <DIGSFindBufferDelegate>)delegate;

@end
