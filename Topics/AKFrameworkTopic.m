/*
 * AKFrameworkTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFrameworkTopic.h"
#import "DIGSLog.h"
#import "AKFrameworkConstants.h"
#import "AKSortUtils.h"
#import "AKDatabase.h"
#import "AKAppDelegate.h"
#import "AKFormalProtocolsTopic.h"
#import "AKInformalProtocolsTopic.h"
#import "AKFunctionsTopic.h"
#import "AKGlobalsTopic.h"

@implementation AKFrameworkTopic

@synthesize database = _database;
@synthesize frameworkName = _frameworkName;

#pragma mark - Init/awake/dealloc

- (instancetype)initWithFramework:(NSString *)frameworkName database:(AKDatabase *)database
{
	NSParameterAssert(frameworkName != nil);
	NSParameterAssert(database != nil);
	self = [super init];
	if (self) {
		_database = database;
		_frameworkName = frameworkName;
	}
	return self;
}

- (instancetype)init
{
	DIGSLogError_NondesignatedInitializer();
	return [self initWithFramework:nil database:nil];
}

#pragma mark - AKTopic methods

- (NSString *)pathInTopicBrowser
{
	return [NSString stringWithFormat:@"%@%@", AKTopicBrowserPathSeparator, self.name];
}

- (NSArray *)_arrayWithChildTopics
{
	NSMutableArray *columnValues = [NSMutableArray array];
	AKDatabase *db = self.database;
	NSString *fwName = self.frameworkName;
	AKTopic *childTopic;

	if ([db formalProtocolsForFramework:fwName].count > 0) {
		childTopic = [[AKFormalProtocolsTopic alloc] initWithFramework:fwName database:db];
		[columnValues addObject:childTopic];
	}

	if ([db informalProtocolsForFramework:fwName].count > 0) {
		childTopic = [[AKInformalProtocolsTopic alloc] initWithFramework:fwName database:db];
		[columnValues addObject:childTopic];
	}
	
	if ([db functionsGroupsForFramework:fwName].count > 0) {
		childTopic = [[AKFunctionsTopic alloc] initWithFramework:fwName database:db];
		[columnValues addObject:childTopic];
	}

	if ([db globalsGroupsForFramework:fwName].count > 0) {
		childTopic = [[AKGlobalsTopic alloc] initWithFramework:fwName database:db];
		[columnValues addObject:childTopic];
	}

	return columnValues;
}

#pragma mark - <AKNamed> methods

- (NSString *)name
{
	return self.frameworkName;
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

	AKDatabase *db = [(AKAppDelegate *)NSApp.delegate appDatabase];
	if (![db hasFrameworkWithName:fwName]) {
		DIGSLogWarning(@"framework %@ named in pref dict for %@ doesn't exist", [self className], fwName);
		return nil;
	}

	// If we got this far, we have what we need to create an instance.
	return [[self alloc] initWithFramework:fwName database:db];
}

- (NSDictionary *)asPrefDictionary
{
	return @{ AKTopicClassNamePrefKey: self.className,
			  AKFrameworkNamePrefKey: self.frameworkName };
}

@end
