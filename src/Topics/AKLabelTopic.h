/*
 * AKLabelTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"

@interface AKLabelTopic : AKTopic
{
    NSString *_label;
}

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (AKLabelTopic *)topicWithLabel:(NSString *)label;

//-------------------------------------------------------------------------
// Getters and setters
//-------------------------------------------------------------------------

- (void)setLabel:(NSString *)label;

@end
