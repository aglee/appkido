/*
 * AKFrameworkTokenClusterTopic.m
 *
 * Created by Andy Lee on Sat May 14 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKFrameworkTokenClusterTopic.h"
#import "AKFramework.h"
#import "AKNamedObjectCluster.h"
#import "DIGSLog.h"

@implementation AKFrameworkTokenClusterTopic

@synthesize framework = _framework;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithNamedObjectCluster:(AKNamedObjectCluster *)namedObjectCluster
								 framework:(AKFramework *)framework
{
	NSParameterAssert(namedObjectCluster != nil);
	NSParameterAssert(framework != nil);
	self = [super initWithNamedObjectCluster:namedObjectCluster];
	if (self) {
		_framework = framework;
	}
	return self;
}

- (instancetype)initWithNamedObjectCluster:(AKNamedObjectCluster *)namedObjectCluster
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithNamedObjectCluster:nil framework:nil];
}

#pragma mark - AKTopic methods

- (NSString *)stringToDisplayInDescriptionField
{
	return [NSString stringWithFormat:@"%@ %@", self.framework.name, self.name];
}

- (NSString *)pathInTopicBrowser
{
	return [NSString stringWithFormat:@"%@%@%@%@",
			AKTopicBrowserPathSeparator,
			self.framework.name,
			AKTopicBrowserPathSeparator,
			self.name];
}

#pragma mark - <AKNamed> methods

- (NSString *)displayName
{
	return [self stringToDisplayInDescriptionField];
}

@end
