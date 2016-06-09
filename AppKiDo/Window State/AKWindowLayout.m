/*
 * AKWindowLayout.m
 *
 * Created by Andy Lee on Sat Jun 14 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKWindowLayout.h"
#import "AKFrameworkConstants.h"
#import "AKPrefConstants.h"

@implementation AKWindowLayout

#pragma mark - Init/awake/dealloc

- (instancetype)init
{
	self = [super init];
	if (self) {
		_toolbarIsVisible = YES;
		_quicklistDrawerIsOpen = YES;
		_quicklistMode = 0;
		_frameworkPopupSelection = AKFoundationFrameworkName;
		_searchIncludesClasses = YES;
		_searchIncludesMembers = YES;
		_searchIncludesFunctionsAndGlobals = YES;
		_searchIgnoresCase = YES;
	}
	return self;
}

#pragma mark - AKPrefDictionary methods

+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict
{
	if (prefDict == nil) {
		return nil;
	}

	AKWindowLayout *windowLayout = [[AKWindowLayout alloc] init];

	windowLayout.windowFrame = NSRectFromString(prefDict[AKWindowFramePrefKey]);
	windowLayout.toolbarIsVisible = [prefDict[AKToolbarIsVisiblePrefKey] boolValue];
	windowLayout.middleViewHeight = [prefDict[AKMiddleViewHeightPrefKey] floatValue];
	windowLayout.subtopicListWidth = [prefDict[AKSubtopicListWidthPrefKey] floatValue];
	windowLayout.browserIsVisible = [prefDict[AKBrowserIsVisiblePrefKey] boolValue];
	windowLayout.browserFraction = [prefDict[AKBrowserFractionPrefKey] floatValue];
	windowLayout.browserHeight = [prefDict[AKBrowserHeightPrefKey] floatValue];
	windowLayout.numberOfBrowserColumns = [prefDict[AKNumberOfBrowserColumnsPrefKey] intValue];
	windowLayout.quicklistDrawerIsOpen = [prefDict[AKQuicklistDrawerIsOpenPrefKey] boolValue];
	windowLayout.quicklistDrawerWidth = [prefDict[AKQuicklistDrawerWidthPrefKey] floatValue];
	windowLayout.quicklistMode = [prefDict[AKQuicklistModePrefKey] intValue];

	NSString *frameworkSelection = prefDict[AKFrameworkPopupSelectionPrefKey];
	if (frameworkSelection != nil) {
		windowLayout.frameworkPopupSelection = frameworkSelection;
	}

	windowLayout.searchIncludesClasses = [prefDict[AKIncludeClassesAndProtocolsPrefKey] boolValue];
	windowLayout.searchIncludesMembers = [prefDict[AKIncludeMethodsPrefKey] boolValue];
	windowLayout.searchIncludesFunctionsAndGlobals = [prefDict[AKIncludeFunctionsAndGlobalsPrefKey] boolValue];
	windowLayout.searchIgnoresCase = [prefDict[AKIgnoreCasePrefKey] boolValue];

	return windowLayout;
}

- (NSDictionary *)asPrefDictionary
{
	NSMutableDictionary *prefDict = [NSMutableDictionary dictionary];

	prefDict[AKWindowFramePrefKey] = NSStringFromRect(self.windowFrame);
	prefDict[AKToolbarIsVisiblePrefKey] = @(self.toolbarIsVisible);
	prefDict[AKMiddleViewHeightPrefKey] = @(self.middleViewHeight);
	prefDict[AKSubtopicListWidthPrefKey] = @(self.subtopicListWidth);
	prefDict[AKBrowserIsVisiblePrefKey] = @(self.browserIsVisible);
	prefDict[AKBrowserFractionPrefKey] = @(self.browserFraction);
	prefDict[AKBrowserHeightPrefKey] = @(self.browserHeight);
	prefDict[AKNumberOfBrowserColumnsPrefKey] = @(self.numberOfBrowserColumns);
	prefDict[AKQuicklistDrawerIsOpenPrefKey] = @(self.quicklistDrawerIsOpen);
	prefDict[AKQuicklistDrawerWidthPrefKey] = @(self.quicklistDrawerWidth);
	prefDict[AKQuicklistModePrefKey] = @(self.quicklistMode);

	if (self.frameworkPopupSelection) {
		prefDict[AKFrameworkPopupSelectionPrefKey] = self.frameworkPopupSelection;
	}

	prefDict[AKIncludeClassesAndProtocolsPrefKey] = @(self.searchIncludesClasses);
	prefDict[AKIncludeMethodsPrefKey] = @(self.searchIncludesMembers);
	prefDict[AKIncludeFunctionsAndGlobalsPrefKey] = @(self.searchIncludesFunctionsAndGlobals);
	prefDict[AKIgnoreCasePrefKey] = @(self.searchIgnoresCase);

	return prefDict;
}

@end
