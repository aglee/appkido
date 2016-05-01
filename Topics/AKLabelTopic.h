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
{
@private
    NSString *_label;
}

@property (nonatomic, copy) NSString *label;

#pragma mark - String constants

extern NSString *AKClassesLabelTopicName;
extern NSString *AKOtherTopicsLabelTopicName;

#pragma mark - Factory methods

+ (AKLabelTopic *)topicWithLabel:(NSString *)label;

@end
