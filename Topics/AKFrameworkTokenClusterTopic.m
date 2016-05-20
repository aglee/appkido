/*
 * AKFrameworkTokenClusterTopic.m
 *
 * Created by Andy Lee on Sat May 14 2005.
 * Copyright (c) 2005 Andy Lee. All rights reserved.
 */

#import "AKFrameworkTokenClusterTopic.h"
#import "AKFramework.h"
#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"
#import "AKSubtopic.h"
#import "DIGSLog.h"

@interface AKFrameworkTokenClusterTopic ()
@property (strong, readonly) AKNamedObjectCluster *tokenCluster;
@end

@implementation AKFrameworkTokenClusterTopic

@synthesize tokenCluster = _tokenCluster;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithFramework:(AKFramework *)framework
					 tokenCluster:(AKNamedObjectCluster *)tokenCluster
{
	NSParameterAssert(tokenCluster != nil);
	self = [super initWithFramework:framework];
	if (self) {
		_tokenCluster = tokenCluster;
	}
	return self;
}

- (instancetype)initWithFramework:(AKFramework *)framework
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithFramework:nil tokenCluster:nil];
}

#pragma mark - AKTopic methods

- (NSString *)stringToDisplayInDescriptionField
{
	return [NSString stringWithFormat:@"%@ %@", self.framework.name, self.name];
}

- (NSString *)pathInTopicBrowser
{
	return [NSString stringWithFormat:@"%@%@%@%@",
			AKTopicBrowserPathSeparator, self.framework.name,
			AKTopicBrowserPathSeparator, self.name];
}

- (NSArray *)_arrayWithSubtopics
{
	NSMutableArray *subtopics = [[NSMutableArray alloc] init];
	for (AKNamedObjectGroup *group in self.tokenCluster.sortedGroups) {
		AKSubtopic *subtopic = [[AKSubtopic alloc] initWithName:group.name
												   docListItems:group.sortedObjects];
		[subtopics addObject:subtopic];
	}
	return subtopics;
}

#pragma mark - <AKNamed> methods

- (NSString *)name
{
	return self.tokenCluster.name;
}

@end
