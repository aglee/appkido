/*
 * AKLabelTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"

@interface AKLabelTopic : AKTopic
{
@private
    NSString *_label;
}

#pragma mark -
#pragma mark Factory methods

+ (AKLabelTopic *)topicWithLabel:(NSString *)label;

#pragma mark -
#pragma mark Getters and setters

- (void)setLabel:(NSString *)label;

@end
