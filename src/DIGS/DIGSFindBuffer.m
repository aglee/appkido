/*
 * DIGSFindBuffer.m
 *
 * Created by Andy Lee on Sat May 17 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "DIGSFindBuffer.h"

@implementation DIGSFindBuffer

#pragma mark -
#pragma mark Factory methods

+ (DIGSFindBuffer *)sharedInstance
{
    static DIGSFindBuffer *s_sharedInstance = nil;
    
    if (!s_sharedInstance)
    {
        s_sharedInstance = [[self alloc] init];
    }

    return s_sharedInstance;
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)init
{
    if ((self = [super init]))
    {
        _findString = @"";
        _listenerPointers = [[NSMutableArray alloc] init];
        _listenerActions = [[NSMutableArray alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_handleAppDidActivateNotification:)
                                                     name:NSApplicationDidBecomeActiveNotification
                                                   object:NSApp];
        [self _loadFindStringFromPasteboard];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_findString release];
    [_listenerPointers release];
    [_listenerActions release];

    [super dealloc];
}

#pragma mark -
#pragma mark Getters and setters

- (NSString *)findString
{
    return _findString;
}

- (void)setFindString:(NSString *)string
{
    if (string == nil)
    {
        string = @"";
    }
    [self _setFindString:string writeToPasteboard:YES];
}

#pragma mark -
#pragma mark Managing listeners

- (void)addListener:(id)listenerObject withSelector:(SEL)handlerSelector
{
    NSValue *pointerHolder = [NSValue valueWithNonretainedObject:listenerObject];
    NSUInteger listenerIndex = [_listenerPointers indexOfObject:pointerHolder];

    if (listenerIndex == NSNotFound)
    {
        NSValue *actionHolder = [NSValue valueWithBytes:&handlerSelector objCType:@encode(SEL)];

        [_listenerPointers addObject:pointerHolder];
        [_listenerActions addObject:actionHolder];
    }
}

- (void)removeListener:(id)listenerObject
{
    NSValue *pointerHolder = [NSValue valueWithNonretainedObject:listenerObject];
    NSUInteger listenerIndex = [_listenerPointers indexOfObject:pointerHolder];

    if (listenerIndex != NSNotFound)
    {
        [_listenerPointers removeObjectAtIndex:listenerIndex];
        [_listenerActions removeObjectAtIndex:listenerIndex];
    }
}

#pragma mark -
#pragma mark Private methods

// Sets the find buffer and updates the UI accordingly.  If flag is YES,
// copies the find buffer to the system find-pasteboard.
- (void)_setFindString:(NSString *)string writeToPasteboard:(BOOL)flag
{
    if ([string isEqualToString:_findString])
    {
        return;
    }

    [_findString autorelease];
    _findString = [string copy];

    if (flag)
    {
        [self _writeFindStringToPasteboard];
    }

    [self _notifyListeners];
}

- (void)_loadFindStringFromPasteboard
{
    NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSFindPboard];

    if ([[pasteboard types] containsObject:NSStringPboardType])
    {
        NSString *string = [pasteboard stringForType:NSStringPboardType];

        if (string && [string length])
        {
            [self _setFindString:string writeToPasteboard:NO];
        }
    }
}

- (void)_writeFindStringToPasteboard
{
    NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSFindPboard];
    NSArray *pasteboardTypes = [NSArray arrayWithObject:NSStringPboardType];

    [pasteboard declareTypes:pasteboardTypes owner:nil];
    [pasteboard setString:[self findString] forType:NSStringPboardType];
}

// This is called whenever the application is activated.
- (void)_handleAppDidActivateNotification:(NSNotification *)ignored
{
    NSString *oldFindString = _findString;

    [self _loadFindStringFromPasteboard];
    if (![_findString isEqualToString:oldFindString])
    {
        [self _notifyListeners];
    }
}

// Tells listeners that the find string has changed.
- (void)_notifyListeners
{
    NSInteger numListeners = [_listenerPointers count];
    NSInteger i;

    for (i = 0; i < numListeners; i++)
    {
        NSValue *pointerHolder = [_listenerPointers objectAtIndex:i];
        id listenerObject = [pointerHolder nonretainedObjectValue];
        NSValue *actionHolder = [_listenerActions objectAtIndex:i];
        SEL actionSelector;

        [actionHolder getValue:&actionSelector];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [listenerObject performSelector:actionSelector withObject:self];
#pragma clang diagnostic pop
    }
}

@end
