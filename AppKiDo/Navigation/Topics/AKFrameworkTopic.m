/*
 * AKFrameworkTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFrameworkTopic.h"
#import "AKAppDelegate.h"
#import "AKDatabase.h"
#import "AKFramework.h"
#import "AKFrameworkConstants.h"
#import "AKFrameworkProtocolsTopic.h"
#import "AKFrameworkTokenClusterTopic.h"
#import "AKNamedObjectCluster.h"
#import "AKNamedObjectGroup.h"
#import "DIGSLog.h"

@implementation AKFrameworkTopic

#pragma mark - AKTopic methods

- (NSString *)pathInTopicBrowser
{
	return [NSString stringWithFormat:@"%@%@", AKTopicBrowserPathSeparator, self.name];
}

- (NSArray *)_arrayWithChildTopics
{
	NSMutableArray *childTopics = [NSMutableArray array];

	if (self.framework.protocolsGroup.count > 0) {
		AKTopic *protocolsTopic = [[AKFrameworkProtocolsTopic alloc] initWithFramework:self.framework];
		[childTopics addObject:protocolsTopic];
	}

	NSArray *tokenClusters = @[self.framework.functionsCluster,
							   self.framework.enumsCluster,
							   self.framework.macrosCluster,
							   self.framework.typedefsCluster,
							   self.framework.constantsCluster];
	for (AKNamedObjectCluster *cluster in tokenClusters) {
		if (cluster.count > 0) {
			AKTopic *child = [[AKFrameworkTokenClusterTopic alloc] initWithFramework:self.framework tokenCluster:cluster];
			[childTopics addObject:child];
		}
	}

	return childTopics;
}

#pragma mark - <AKNamed> methods

- (NSString *)name
{
	return self.framework.name;
}

#pragma mark - AKPrefDictionary methods

+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict
{
	if (prefDict == nil) {
		return nil;
	}

	// Get the framework name.
	NSString *fwName = prefDict[AKFrameworkNamePrefKey];

	if ([fwName isEqualToString:@"ApplicationKit"]) {
		// In older versions of AppKiDo, "AppKit" was saved as "ApplicationKit" in prefs.
		fwName = AKAppKitFrameworkName;
	}

	if (fwName == nil) {
		DIGSLogWarning(@"malformed pref dictionary for class %@", [self className]);
		return nil;
	}

	AKDatabase *db = [(AKAppDelegate *)NSApp.delegate appDatabase];  //TODO: Global database.
	AKFramework *framework = [db frameworkWithName:fwName];
	if (framework == nil) {
		DIGSLogWarning(@"framework %@ named in pref dict for %@ doesn't exist", [self className], fwName);
		return nil;
	}

	// If we got this far, we have what we need to create an instance.
	return [[self alloc] initWithFramework:framework];
}

- (NSDictionary *)asPrefDictionary
{
	return @{ AKTopicClassNamePrefKey: self.className,
			  AKFrameworkNamePrefKey: self.framework.name };
}

@end
