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

@synthesize windowFrame = _windowFrame;
@synthesize toolbarIsVisible = _toolbarIsVisible;
@synthesize browserIsVisible = _browserIsVisible;
@synthesize browserFraction = _browserFraction;
@synthesize browserHeight = _browserHeight;
@synthesize numberOfBrowserColumns = _numberOfBrowserColumns;
@synthesize middleViewHeight = _middleViewHeight;
@synthesize subtopicListWidth = _subtopicListWidth;
@synthesize quicklistDrawerIsOpen = _quicklistDrawerIsOpen;
@synthesize quicklistDrawerWidth = _quicklistDrawerWidth;
@synthesize quicklistMode = _quicklistMode;
@synthesize frameworkPopupSelection = _frameworkPopupSelection;
@synthesize searchIncludesClasses = _searchIncludesClasses;
@synthesize searchIncludesMembers = _searchIncludesMembers;
@synthesize searchIncludesFunctions = _searchIncludesFunctions;
@synthesize searchIncludesGlobals = _searchIncludesGlobals;
@synthesize searchIgnoresCase = _searchIgnoresCase;

#pragma mark - Init/awake/dealloc

- (instancetype)init
{
    if ((self = [super init]))
    {
        _toolbarIsVisible = YES;
        _quicklistDrawerIsOpen = YES;
        _quicklistMode = 0;
        _frameworkPopupSelection = AKFoundationFrameworkName;
        _searchIncludesClasses = YES;
        _searchIncludesMembers = YES;
        _searchIncludesFunctions = YES;
        _searchIncludesGlobals = YES;
        _searchIgnoresCase = YES;
    }

    return self;
}


#pragma mark - AKPrefDictionary methods

+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict
{
    if (prefDict == nil)
    {
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
    if (frameworkSelection != nil)
    {
        windowLayout.frameworkPopupSelection = frameworkSelection;
    }

    windowLayout.searchIncludesClasses = [prefDict[AKIncludeClassesAndProtocolsPrefKey] boolValue];
    windowLayout.searchIncludesMembers = [prefDict[AKIncludeMethodsPrefKey] boolValue];
    windowLayout.searchIncludesFunctions = [prefDict[AKIncludeFunctionsPrefKey] boolValue];
    windowLayout.searchIncludesGlobals = [prefDict[AKIncludeGlobalsPrefKey] boolValue];
    windowLayout.searchIgnoresCase = [prefDict[AKIgnoreCasePrefKey] boolValue];

    return windowLayout;
}

- (NSDictionary *)asPrefDictionary
{
    NSMutableDictionary *prefDict = [NSMutableDictionary dictionary];

    prefDict[AKWindowFramePrefKey] = NSStringFromRect(_windowFrame);
    prefDict[AKToolbarIsVisiblePrefKey] = @(_toolbarIsVisible);
    prefDict[AKMiddleViewHeightPrefKey] = @(_middleViewHeight);
    prefDict[AKSubtopicListWidthPrefKey] = @(_subtopicListWidth);
    prefDict[AKBrowserIsVisiblePrefKey] = @(_browserIsVisible);
    prefDict[AKBrowserFractionPrefKey] = @(_browserFraction);
    prefDict[AKBrowserHeightPrefKey] = @(_browserHeight);
    prefDict[AKNumberOfBrowserColumnsPrefKey] = @(_numberOfBrowserColumns);
    prefDict[AKQuicklistDrawerIsOpenPrefKey] = @(_quicklistDrawerIsOpen);
    prefDict[AKQuicklistDrawerWidthPrefKey] = @(_quicklistDrawerWidth);
    prefDict[AKQuicklistModePrefKey] = @(_quicklistMode);

    if (_frameworkPopupSelection)
    {
        prefDict[AKFrameworkPopupSelectionPrefKey] = _frameworkPopupSelection;
    }

    prefDict[AKIncludeClassesAndProtocolsPrefKey] = @(_searchIncludesClasses);
    prefDict[AKIncludeMethodsPrefKey] = @(_searchIncludesMembers);
    prefDict[AKIncludeFunctionsPrefKey] = @(_searchIncludesFunctions);
    prefDict[AKIncludeGlobalsPrefKey] = @(_searchIncludesGlobals);
    prefDict[AKIgnoreCasePrefKey] = @(_searchIgnoresCase);

    return prefDict;
}

@end
