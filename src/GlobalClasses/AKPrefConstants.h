/*
 * AKPrefConstants.h
 *
 * Created by Andy Lee on Wed Mar 31 2004.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>


#pragma mark -
#pragma mark AKXyzPrefName
//
// Keys for NSUserDefaults.

// Value is a dictionary that can be converted to an AKWindowLayout.
extern NSString *AKLayoutForNewWindowsPrefName;

// Value is an array whose elements are instances of NSDictionary
// containing AKSavedWindowState info.
extern NSString *AKSavedWindowStatesPrefName;

// Value is an int that specifies the maximum number of past search
// strings to remember.
extern NSString *AKMaxSearchStringsPrefName;

// Value is a string that specifies the name of the font to use for list
// boxes and browsers.
extern NSString *AKListFontNamePrefName;

// Value is an int that specifies what font size to use for list boxes
// and browsers.
extern NSString *AKListFontSizePrefName;

// Value is a string that specifies the name of the font to use for
// displaying header files.
extern NSString *AKHeaderFontNamePrefName;

// Value is an int that specifies what font size to use for displaying
// header files.
extern NSString *AKHeaderFontSizePrefName;

// Value is an int that specifies the percent magnification to use for
// displaying documentation.  A value of 100 means no magnification.
extern NSString *AKDocMagnificationPrefName;

// Value is a boolean that specifies whether to use textured windows.
// If not, Aqua windows are used.
extern NSString *AKUseTexturedWindowsPrefName;  // [agl] NOTE: This option is no longer offered.

// Value is an int that specifies the maximum number of items to store in
// each window's navigation history.
extern NSString *AKMaxHistoryPrefName;

// Value is an array whose elements are dictionaries that will be passed to
// [NSTopic +fromPrefDictionary].  This is used to generate the items
// displayed in the Favorites list.
extern NSString *AKFavoritesPrefName;

// Value is an array whose elements are names of the frameworks that are
// selected in the Frameworks tab of the Prefs panel.
extern NSString *AKSelectedFrameworksPrefName;

// Value is the top-level directory where the Dev Tools are located, e.g.,
// @"/Developer".
extern NSString *AKDevToolsPathPrefName;

// Value is version number of the SDK for which we should get all our data --
// see AKDevTools.
extern NSString *AKSDKVersionPrefName;

extern NSString *AKSearchInNewWindowPrefName;


#pragma mark -
#pragma mark AKXyzPrefKey
//
// Keys within pref values that are of type NSDictionary.

// For storing instances of various AKTopic classes as pref
// dictionaries.
extern NSString *AKTopicClassNamePrefKey;       // string
extern NSString *AKLabelStringPrefKey;          // string
extern NSString *AKBehaviorNamePrefKey;         // string
extern NSString *AKFrameworkNamePrefKey;        // string
extern NSString *AKParentBrowserPathPrefKey;    // string

// For storing an AKDocLocator as a pref dictionary
extern NSString *AKTopicPrefKey;     // dict <-> AKTopic
extern NSString *AKSubtopicPrefKey;  // string
extern NSString *AKDocNamePrefKey;   // string

// For storing an AKWindowLayout as a pref dictionary.
extern NSString *AKWindowFramePrefKey;                 // string <-> rect
extern NSString *AKToolbarIsVisiblePrefKey;            // boolean
extern NSString *AKMiddleViewHeightPrefKey;            // float
extern NSString *AKSubtopicListWidthPrefKey;           // float
extern NSString *AKBrowserIsVisiblePrefKey;            // boolean
extern NSString *AKBrowserFractionPrefKey;             // float
extern NSString *AKNumberOfBrowserColumnsPrefKey;      // int
extern NSString *AKQuicklistDrawerIsOpenPrefKey;       // boolean
extern NSString *AKQuicklistDrawerWidthPrefKey;        // float
extern NSString *AKQuicklistModePrefKey;               // int
extern NSString *AKIncludeClassesAndProtocolsPrefKey;  // boolean
extern NSString *AKIncludeMethodsPrefKey;              // boolean
extern NSString *AKIncludeFunctionsPrefKey;            // boolean
extern NSString *AKIncludeGlobalsPrefKey;    // boolean
extern NSString *AKIgnoreCasePrefKey;                  // boolean
extern NSString *AKFrameworkPopupSelectionPrefKey;     // string

// For storing an AKSavedWindowState as a pref dictionary.
extern NSString *AKWindowLayoutPrefKey;  // dict <-> AKWindowLayout
extern NSString *AKSelectedDocPrefKey;   // dict <-> AKDocLocator
