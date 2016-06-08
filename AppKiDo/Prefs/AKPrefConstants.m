/*
 * AKPrefConstants.m
 *
 * Created by Andy Lee on Wed Mar 31 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKPrefConstants.h"


#pragma mark - Keys for NSUserDefaults

NSString *AKLayoutForNewWindowsPrefName       = @"AKLayoutForNewWindows";
NSString *AKSavedWindowStatesPrefName         = @"AKSavedWindowStates";
NSString *AKMaxSearchStringsPrefName          = @"AKMaxSearchStrings";
NSString *AKIncludeClassesAndProtocolsPrefKey = @"AKIncludeClasses";
NSString *AKIncludeMethodsPrefKey             = @"AKIncludeMethods";
NSString *AKIncludeFunctionsPrefKey           = @"AKIncludeFunctions";
NSString *AKIncludeGlobalsPrefKey             = @"AKIncludeTypes";
NSString *AKIgnoreCasePrefKey                 = @"AKIgnoreCase";
NSString *AKListFontNamePrefName              = @"AKListFontName";
NSString *AKListFontSizePrefName              = @"AKListFontSize";
NSString *AKHeaderFontNamePrefName            = @"AKHeaderFontName";
NSString *AKHeaderFontSizePrefName            = @"AKHeaderFontSize";
NSString *AKDocMagnificationPrefName          = @"AKDocMagnification";
NSString *AKUseTexturedWindowsPrefName        = @"AKTexturedWindows";
NSString *AKMaxHistoryPrefName                = @"AKMaxHistory";

NSString *AKFavoritesPrefName = @"AKFavorites";

NSString *AKSelectedFrameworksPrefName = @"AKSelectedFrameworks";
NSString *AKXcodePathPrefName = @"AKXcodePath";
NSString *AKSDKVersionPrefName = @"AKSDKVersion";

NSString *AKSearchInNewWindowPrefName         = @"AKSearchInNewWindow";

#pragma mark - "PrefKey" = key within a pref that is a dictionary

// For storing instances of various AKTopic classes as pref
// dictionaries.
NSString *AKTopicClassNamePrefKey       = @"TopicClassName";
NSString *AKLabelStringPrefKey          = @"LabelString";
NSString *AKBehaviorNamePrefKey         = @"InterfaceName";
NSString *AKFrameworkNamePrefKey        = @"FrameworkName";
NSString *AKParentBrowserPathPrefKey    = @"ParentBrowserPath";

// For storing instances of various AKDocLocator classes as pref dictionaries.
NSString *AKTopicPrefKey    = @"Topic";
NSString *AKSubtopicPrefKey = @"Subtopic";
NSString *AKDocNamePrefKey  = @"DocName";

// For storing an AKWindowLayout as a pref dictionary.
NSString *AKWindowFramePrefKey             = @"WindowFrame";
NSString *AKToolbarIsVisiblePrefKey        = @"ToolbarIsVisible";
NSString *AKMiddleViewHeightPrefKey        = @"MiddleViewHeight";
NSString *AKSubtopicListWidthPrefKey       = @"SubtopicListWidth";
NSString *AKBrowserIsVisiblePrefKey        = @"BrowserIsVisible";
NSString *AKBrowserFractionPrefKey         = @"BrowserFraction";
NSString *AKBrowserHeightPrefKey           = @"BrowserHeight";
NSString *AKNumberOfBrowserColumnsPrefKey  = @"NumBrowserColumns";
NSString *AKQuicklistDrawerIsOpenPrefKey   = @"DrawerIsOpen";
NSString *AKQuicklistDrawerWidthPrefKey    = @"DrawerWidth";
NSString *AKQuicklistModePrefKey           = @"QuicklistMode";
NSString *AKFrameworkPopupSelectionPrefKey = @"SelectedFramework";

// For storing an AKSavedWindowState as a pref dictionary.
NSString *AKWindowLayoutPrefKey = @"WindowLayout";
NSString *AKSelectedDocPrefKey  = @"HistoryItem";
