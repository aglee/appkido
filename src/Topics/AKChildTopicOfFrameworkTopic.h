/*
 * AKChildTopicOfFrameworkTopic.h
 *
 * Created by Andy Lee on Sat May 14 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKFrameworkTopic.h"

/*!
 * Abstract class used for child topics of an AKFrameworkTopic. When a framework
 * is selected in the topic browser, the next column is populated with instances
 * of AKChildTopicOfFrameworkTopic classes.
 *
 * Subclasses must implement stringToDisplayInTopicBrowser.
 */
@interface AKChildTopicOfFrameworkTopic : AKFrameworkTopic
@end
