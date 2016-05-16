/*
 * AKTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "AKTopicBrowserItem.h"
#import "AKPrefDictionary.h"
#import "AKPrefUtils.h"
#import "AKTopicConstants.h"

@class AKClassToken;
@class AKToken;
@class AKSubtopic;

/*!
 * Abstract class that represents a "topic". Used as the representedObject of
 * cells in the topic browser.
 *
 * IMPORTANT TERMINOLOGY: when a topic is selected in the topic browser, the
 * selected AKTopic provides **child topics** for populating the next column of
 * the browser, and **subtopics** for populating the subtopics list. For
 * example, when a class is selected in the topic browser, the **child topics**
 * are the class's subclasses and the **subtopics** include "Class Methods",
 * "Instance Methods", etc.
 */
@interface AKTopic : NSObject <AKPrefDictionary, AKTopicBrowserItem>

#pragma mark - Convenience method

- (AKSubtopic *)subtopicWithName:(NSString *)name
					docListItems:(NSArray *)docListItems
							sort:(BOOL)sort;

@end
