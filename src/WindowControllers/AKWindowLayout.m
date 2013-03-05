/*
 * AKWindowLayout.m
 *
 * Created by Andy Lee on Sat Jun 14 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKWindowLayout.h"

#import "AKFrameworkConstants.h"

@implementation AKWindowLayout

@synthesize windowFrame = _windowFrame;
@synthesize toolbarIsVisible = _toolbarIsVisible;
@synthesize browserIsVisible = _browserIsVisible;
@synthesize browserFraction = _browserFraction;
@synthesize numberOfBrowserColumns = _numberOfBrowserColumns;
@synthesize middleViewHeight = _middleViewHeight;
@synthesize quicklistDrawerIsOpen = _quicklistDrawerIsOpen;
@synthesize quicklistDrawerWidth = _quicklistDrawerWidth;
@synthesize quicklistMode = _quicklistMode;
@synthesize frameworkPopupSelection = _frameworkPopupSelection;
@synthesize searchIncludesClasses = _searchIncludesClasses;
@synthesize searchIncludesMembers = _searchIncludesMembers;
@synthesize searchIncludesFunctions = _searchIncludesFunctions;
@synthesize searchIncludesGlobals = _searchIncludesGlobals;
@synthesize searchIgnoresCase = _searchIgnoresCase;

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)init
{
    if ((self = [super init]))
    {
        _toolbarIsVisible = YES;
        _quicklistDrawerIsOpen = YES;
        _quicklistMode = 0;
        _frameworkPopupSelection = [AKFoundationFrameworkName copy];
        _searchIncludesClasses = YES;
        _searchIncludesMembers = YES;
        _searchIncludesFunctions = YES;
        _searchIncludesGlobals = YES;
        _searchIgnoresCase = YES;
    }

    return self;
}

- (void)dealloc
{
    [_frameworkPopupSelection release];

    [super dealloc];
}

#pragma mark -
#pragma mark Preferences

+ (AKWindowLayout *)fromPrefDictionary:(NSDictionary *)prefDict
{
    if (prefDict == nil)
    {
        return nil;
    }

    AKWindowLayout *windowLayout = [[[AKWindowLayout alloc] init] autorelease];

    [windowLayout setWindowFrame:NSRectFromString([prefDict objectForKey:AKWindowFramePrefKey])];
    [windowLayout setToolbarIsVisible:[[prefDict objectForKey:AKToolbarIsVisiblePrefKey] boolValue]];
    [windowLayout setMiddleViewHeight:[[prefDict objectForKey:AKMiddleViewHeightPrefKey] floatValue]];
    [windowLayout setBrowserIsVisible:[[prefDict objectForKey:AKBrowserIsVisiblePrefKey] boolValue]];
    [windowLayout setBrowserFraction:[[prefDict objectForKey:AKBrowserFractionPrefKey] floatValue]];
    [windowLayout setNumberOfBrowserColumns:[[prefDict objectForKey:AKNumberOfBrowserColumnsPrefKey] intValue]];
    [windowLayout setQuicklistDrawerIsOpen:[[prefDict objectForKey:AKQuicklistDrawerIsOpenPrefKey] boolValue]];
    [windowLayout setQuicklistDrawerWidth:[[prefDict objectForKey:AKQuicklistDrawerWidthPrefKey] floatValue]];
    [windowLayout setQuicklistMode:[[prefDict objectForKey:AKQuicklistModePrefKey] intValue]];

    NSString *frameworkSelection = [prefDict objectForKey:AKFrameworkPopupSelectionPrefKey];
    if (frameworkSelection != nil)
    {
        [windowLayout setFrameworkPopupSelection:frameworkSelection];
    }

    [windowLayout setSearchIncludesClasses:[[prefDict objectForKey:AKIncludeClassesAndProtocolsPrefKey] boolValue]];
    [windowLayout setSearchIncludesMembers:[[prefDict objectForKey:AKIncludeMethodsPrefKey] boolValue]];
    [windowLayout setSearchIncludesFunctions:[[prefDict objectForKey:AKIncludeFunctionsPrefKey] boolValue]];
    [windowLayout setSearchIncludesGlobals:[[prefDict objectForKey:AKIncludeGlobalsPrefKey] boolValue]];
    [windowLayout setSearchIgnoresCase:[[prefDict objectForKey:AKIgnoreCasePrefKey] boolValue]];

    return windowLayout;
}

- (NSDictionary *)asPrefDictionary
{
    NSMutableDictionary *prefDict = [NSMutableDictionary dictionary];

    [prefDict setObject:NSStringFromRect(_windowFrame) forKey:AKWindowFramePrefKey];
    [prefDict setObject:@(_toolbarIsVisible) forKey:AKToolbarIsVisiblePrefKey];
    [prefDict setObject:@(_middleViewHeight) forKey:AKMiddleViewHeightPrefKey];
    [prefDict setObject:@(_browserIsVisible) forKey:AKBrowserIsVisiblePrefKey];
    [prefDict setObject:@(_browserFraction) forKey:AKBrowserFractionPrefKey];
    [prefDict setObject:@(_numberOfBrowserColumns) forKey:AKNumberOfBrowserColumnsPrefKey];
    [prefDict setObject:@(_quicklistDrawerIsOpen) forKey:AKQuicklistDrawerIsOpenPrefKey];
    [prefDict setObject:@(_quicklistDrawerWidth) forKey:AKQuicklistDrawerWidthPrefKey];
    [prefDict setObject:@(_quicklistMode) forKey:AKQuicklistModePrefKey];

    if (_frameworkPopupSelection)
    {
        [prefDict setObject:_frameworkPopupSelection forKey:AKFrameworkPopupSelectionPrefKey];
    }

    [prefDict setObject:@(_searchIncludesClasses) forKey:AKIncludeClassesAndProtocolsPrefKey];
    [prefDict setObject:@(_searchIncludesMembers) forKey:AKIncludeMethodsPrefKey];
    [prefDict setObject:@(_searchIncludesFunctions) forKey:AKIncludeFunctionsPrefKey];
    [prefDict setObject:@(_searchIncludesGlobals) forKey:AKIncludeGlobalsPrefKey];
    [prefDict setObject:@(_searchIgnoresCase) forKey:AKIgnoreCasePrefKey];

    return prefDict;
}

@end
