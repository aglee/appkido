/*
 * AKBehaviorTopic.m
 *
 * Created by Andy Lee on Mon May 26 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKBehaviorTopic.h"
#import "DIGSLog.h"

@implementation AKBehaviorTopic

#pragma mark - <AKPrefDictionary> methods

- (NSDictionary *)asPrefDictionary
{
	return @{ AKTopicClassNamePrefKey : self.className,
			  AKBehaviorNamePrefKey : self.name };
}

@end
