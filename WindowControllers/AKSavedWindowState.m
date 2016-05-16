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

#pragma mark - AKPrefDictionary methods

+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict
{
	if (prefDict == nil) {
		return nil;
	}

	AKSavedWindowState *windowState = [[self alloc] init];

	// Get the window layout.
	NSDictionary *windowLayoutPrefDict = prefDict[AKWindowLayoutPrefKey];
	AKWindowLayout *windowLayout = [AKWindowLayout fromPrefDictionary:windowLayoutPrefDict];
	windowState.savedWindowLayout = windowLayout;

	// Get the window's selected history item.
	NSDictionary *docLocatorPrefDict = prefDict[AKSelectedDocPrefKey];
	AKDocLocator *docLocator = [AKDocLocator fromPrefDictionary:docLocatorPrefDict];
	windowState.savedDocLocator = docLocator;

	return windowState;
}

- (NSDictionary *)asPrefDictionary
{
	return @{ AKWindowLayoutPrefKey: [self.savedWindowLayout asPrefDictionary],
			  AKSelectedDocPrefKey: [self.savedDocLocator asPrefDictionary] };
}

@end
