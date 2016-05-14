/*
 * AKLabelTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"

/*!
 * Not a real topic. Used for displaying label text in the topic browser.
 */
@interface AKLabelTopic : AKTopic

@property (copy) NSString *label;

extern NSString *AKClassesLabelTopicName;
extern NSString *AKOtherTopicsLabelTopicName;

+ (AKLabelTopic *)topicWithLabel:(NSString *)label;

@end
