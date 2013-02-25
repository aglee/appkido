/*
 * AKChildTopicOfFrameworkTopic.h
 *
 * Created by Andy Lee on Sat May 14 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKFrameworkTopic.h"

/*!
 * Intermediate class holding shared behavior of topics that are related to a
 * a framework topic. When a framework is selected in the browser, the next
 * next column is populated with instances of this.
 *
 * Subclasses reflect the type of framework and must implement
 * -stringToDisplayInTopicBrowser.
 */
@interface AKChildTopicOfFrameworkTopic : AKFrameworkTopic
@end
