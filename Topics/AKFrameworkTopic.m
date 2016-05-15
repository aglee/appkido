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

@synthesize topicDatabase = _topicDatabase;
@synthesize topicFrameworkName = _topicFrameworkName;

#pragma mark - Factory methods

+ (AKFrameworkTopic *)topicWithFramework:(NSString *)frameworkName inDatabase:(AKDatabase *)database
{
    return [[self alloc] initWithFramework:frameworkName inDatabase:database];
}

#pragma mark - Init/awake/dealloc

- (instancetype)initWithFramework:(NSString *)frameworkName inDatabase:(AKDatabase *)aDatabase
{
    if ((self = [super init]))
    {
        _topicDatabase = aDatabase;
        _topicFrameworkName = [frameworkName copy];
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithFramework:nil inDatabase:nil];
}


#pragma mark - AKTopic methods

- (NSString *)name
{
    return _topicFrameworkName;
}

- (NSString *)pathInTopicBrowser
{
    return [NSString stringWithFormat:@"%@%@", AKTopicBrowserPathSeparator,
            [self name]];
}

- (NSArray *)childTopics
{
    NSMutableArray *columnValues = [NSMutableArray array];

    if ([_topicDatabase functionsGroupsForFramework:_topicFrameworkName].count > 0)
    {
        [columnValues addObject:[AKFunctionsTopic topicWithFramework:_topicFrameworkName
                                                               inDatabase:_topicDatabase]];
    }

    if ([_topicDatabase globalsGroupsForFramework:_topicFrameworkName].count > 0)
    {
        [columnValues addObject:[AKGlobalsTopic topicWithFramework:_topicFrameworkName
                                                             inDatabase:_topicDatabase]];
    }

    if ([_topicDatabase formalProtocolsForFramework:_topicFrameworkName].count > 0)
    {
        [columnValues addObject:[AKFormalProtocolsTopic topicWithFramework:_topicFrameworkName
                                                                     inDatabase:_topicDatabase]];
    }

    if ([_topicDatabase informalProtocolsForFramework:_topicFrameworkName].count > 0)
    {
        [columnValues addObject:[AKInformalProtocolsTopic topicWithFramework:_topicFrameworkName
                                                                       inDatabase:_topicDatabase]];
    }

    return columnValues;
}

#pragma mark - AKPrefDictionary methods

+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict
{
    if (prefDict == nil)
    {
        return nil;
    }

    // Get the framework name.
    NSString *fwName = prefDict[AKFrameworkNamePrefKey];

    if ([fwName isEqualToString:@"ApplicationKit"])
    {
        // In older versions of AppKiDo, "AppKit" was saved as "ApplicationKit" in prefs.
        fwName = AKAppKitFrameworkName;
    }

    if (fwName == nil)
    {
        DIGSLogWarning(@"malformed pref dictionary for class %@", [self className]);
        return nil;
    }

    AKDatabase *db = [(AKAppDelegate *)NSApp.delegate appDatabase];
    if (![db hasFrameworkWithName:fwName])
    {
        DIGSLogWarning(@"framework %@ named in pref dict for %@ doesn't exist", [self className], fwName);
        return nil;
    }

    // If we got this far, we have what we need to create an instance.
    return [self topicWithFramework:fwName inDatabase:db];
}

- (NSDictionary *)asPrefDictionary
{
    NSMutableDictionary *prefDict = [NSMutableDictionary dictionary];

    prefDict[AKTopicClassNamePrefKey] = self.className;
    prefDict[AKFrameworkNamePrefKey] = _topicFrameworkName;

    return prefDict;
}

@end
