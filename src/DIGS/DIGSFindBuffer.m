/*
 * DIGSFindBuffer.m
 *
 * Created by Andy Lee on Sat May 17 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "DIGSFindBuffer.h"


#pragma mark -
#pragma mark Forward declarations of private methods

@interface DIGSFindBuffer (Private)
- (void)_setFindString:(NSString *)string writeToPasteboard:(BOOL)flag;
- (void)_loadFindStringFromPasteboard;
- (void)_writeFindStringToPasteboard;
- (void)_handleAppDidActivateNotification:(NSNotification *)notification;
- (void)_notifyListeners;
@end

@implementation DIGSFindBuffer


#pragma mark -
#pragma mark Factory methods

static DIGSFindBuffer *s_sharedInstance = nil;

+ (DIGSFindBuffer *)sharedInstance
{
    if (!s_sharedInstance)
    {
        (void)[[self allocWithZone:[[NSApplication sharedApplication] zone]] init];
    }

    return s_sharedInstance;
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)init
{
    if (s_sharedInstance)
    {
        [super dealloc];
        return s_sharedInstance;
    }

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

        s_sharedInstance = self;
    }

    return self;
}

- (void)dealloc
{
    if (self != s_sharedInstance)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        [_findString release];
        [_listenerPointers release];
        [_listenerActions release];

        [super dealloc];
    }
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
    NSUInteger index = [_listenerPointers indexOfObject:pointerHolder];

    if (index == NSNotFound)
    {
        NSValue *actionHolder = [NSValue valueWithBytes:&handlerSelector objCType:@encode(SEL)];

        [_listenerPointers addObject:pointerHolder];
        [_listenerActions addObject:actionHolder];
    }
}

- (void)removeListener:(id)listenerObject
{
    NSValue *pointerHolder = [NSValue valueWithNonretainedObject:listenerObject];
    NSUInteger index = [_listenerPointers indexOfObject:pointerHolder];

    if (index != NSNotFound)
    {
        [_listenerPointers removeObjectAtIndex:index];
        [_listenerActions removeObjectAtIndex:index];
    }
}

@end


#pragma mark -
#pragma mark Private methods

@implementation DIGSFindBuffer (Private)

/*
 * Sets my find buffer and updates the UI accordingly.  If flag is YES,
 * copies my find buffer to the system find-pasteboard.
 */
- (void)_setFindString:(NSString *)string writeToPasteboard:(BOOL)flag
{
    if ([string isEqualToString:_findString])
    {
        return;
    }

    [_findString autorelease];
    _findString = [string copyWithZone:[self zone]];

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

/*
 * This is called whenever the application I am in is activated.
 */
- (void)_handleAppDidActivateNotification:(NSNotification *)ignored
{
    NSString *oldFindString = _findString;

    [self _loadFindStringFromPasteboard];
    if (![_findString isEqualToString:oldFindString])
    {
        [self _notifyListeners];
    }
}

/*
 * Tells my listeners that the find string has changed.
 */
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
        [listenerObject performSelector:actionSelector withObject:self];
    }
}

@end
