/*
 * AKSavedWindowState.m
 *
 * Created by Andy Lee on Sun Jun 15 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKSavedWindowState.h"

#import "AKPrefUtils.h"
#import "AKDatabase.h"
#import "AKWindowLayout.h"
#import "AKDocLocator.h"

@implementation AKSavedWindowState

@synthesize savedWindowLayout = _savedWindowLayout;
@synthesize savedDocLocator = _savedDocLocator;

#pragma mark - Init/awake/dealloc

- (void)dealloc
{
    [_savedWindowLayout release];
    [_savedDocLocator release];

    [super dealloc];
}

#pragma mark -
#pragma mark AKPrefDictionary methods

+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict
{
    if (prefDict == nil)
    {
        return nil;
    }

    AKSavedWindowState *windowState = [[[self alloc] init] autorelease];

    // Get the window layout.
    NSDictionary *windowLayoutPrefDict = [prefDict objectForKey:AKWindowLayoutPrefKey];
    AKWindowLayout *windowLayout = [AKWindowLayout fromPrefDictionary:windowLayoutPrefDict];

    [windowState setSavedWindowLayout:windowLayout];

    // Get the window's selected history item.
    NSDictionary *historyItemPrefDict = [prefDict objectForKey:AKSelectedDocPrefKey];
    AKDocLocator *historyItem = [AKDocLocator fromPrefDictionary:historyItemPrefDict];

    [windowState setSavedDocLocator:historyItem];

    return windowState;
}

- (NSDictionary *)asPrefDictionary
{
    NSMutableDictionary *prefDict = [NSMutableDictionary dictionary];

    [prefDict setObject:[_savedWindowLayout asPrefDictionary] forKey:AKWindowLayoutPrefKey];
    [prefDict setObject:[_savedDocLocator asPrefDictionary] forKey:AKSelectedDocPrefKey];

    return prefDict;
}

@end
