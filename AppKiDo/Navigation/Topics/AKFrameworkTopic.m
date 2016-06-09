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

	if (self.framework.functionsAndGlobalsCluster.count > 0) {
		[childTopics addObject:[self _functionsAndGlobalsTopic]];
	}

	return childTopics;
}

- (AKTopic *)_functionsAndGlobalsTopic
{
	AKNamedObjectCluster *tokenCluster = self.framework.functionsAndGlobalsCluster;
	return [[AKFrameworkTokenClusterTopic alloc] initWithFramework:self.framework
													  tokenCluster:tokenCluster];
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

	AKDatabase *db = AKAppDelegate.appDelegate.appDatabase;  //TODO: Global database.
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
