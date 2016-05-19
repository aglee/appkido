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
#import "AKNamedObjectCluster.h"
#import "AKFrameworkTokenClusterTopic.h"
#import "AKNamedObjectGroup.h"
#import "AKNamedObjectGroupTopic.h"
#import "AKSortUtils.h"
#import "DIGSLog.h"

@implementation AKFrameworkTopic

@synthesize framework = _framework;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithFramework:(AKFramework *)framework
{
	NSParameterAssert(framework != nil);
	self = [super init];
	if (self) {
		_framework = framework;
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithFramework:nil];
}

#pragma mark - AKTopic methods

- (NSString *)pathInTopicBrowser
{
	return [NSString stringWithFormat:@"%@%@", AKTopicBrowserPathSeparator, self.name];
}

- (NSArray *)_arrayWithChildTopics
{
	NSMutableArray *columnValues = [NSMutableArray array];
	AKTopic *childTopic;

	if (self.framework.protocolsGroup.count > 0) {
		childTopic = [[AKNamedObjectGroupTopic alloc] initWithNamedObjectGroup:self.framework.protocolsGroup];
		[columnValues addObject:childTopic];
	}

	NSArray *clusters = @[
						  self.framework.functionsCluster,
						  self.framework.enumsCluster,
						  self.framework.macrosCluster,
						  self.framework.typedefsCluster,
						  self.framework.constantsCluster,
						  ];
	for (AKNamedObjectCluster *cluster in clusters) {
		if (cluster.count > 0) {
			childTopic = [[AKFrameworkTokenClusterTopic alloc] initWithNamedObjectCluster:cluster framework:self.framework];
			[columnValues addObject:childTopic];
		}
	}

	return columnValues;
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
