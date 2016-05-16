/*
 * AKLabelTopic.h
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKTopic.h"

/*!
 * Used for displaying label text in the topic browser.
 */
@interface AKLabelTopic : AKTopic

@property (copy) NSString *label;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithLabel:(NSString *)label;

@end
