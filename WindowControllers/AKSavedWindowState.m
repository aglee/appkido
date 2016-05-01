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


#pragma mark - AKPrefDictionary methods

+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict
{
    if (prefDict == nil)
    {
        return nil;
    }

    AKSavedWindowState *windowState = [[self alloc] init];

    // Get the window layout.
    NSDictionary *windowLayoutPrefDict = prefDict[AKWindowLayoutPrefKey];
    AKWindowLayout *windowLayout = [AKWindowLayout fromPrefDictionary:windowLayoutPrefDict];

    windowState.savedWindowLayout = windowLayout;

    // Get the window's selected history item.
    NSDictionary *historyItemPrefDict = prefDict[AKSelectedDocPrefKey];
    AKDocLocator *historyItem = [AKDocLocator fromPrefDictionary:historyItemPrefDict];

    windowState.savedDocLocator = historyItem;

    return windowState;
}

- (NSDictionary *)asPrefDictionary
{
    NSMutableDictionary *prefDict = [NSMutableDictionary dictionary];

    prefDict[AKWindowLayoutPrefKey] = [_savedWindowLayout asPrefDictionary];
    prefDict[AKSelectedDocPrefKey] = [_savedDocLocator asPrefDictionary];

    return prefDict;
}

@end
