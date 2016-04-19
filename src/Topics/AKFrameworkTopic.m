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

#pragma mark -
#pragma mark Factory methods

+ (AKFrameworkTopic *)topicWithFrameworkNamed:(NSString *)frameworkName inDatabase:(AKDatabase *)database
{
    return [[self alloc] initWithFrameworkNamed:frameworkName inDatabase:database];
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithFrameworkNamed:(NSString *)frameworkName inDatabase:(AKDatabase *)aDatabase
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
    return nil;
}


#pragma mark -
#pragma mark AKTopic methods

- (NSString *)stringToDisplayInTopicBrowser
{
    return _topicFrameworkName;
}

- (NSString *)pathInTopicBrowser
{
    return [NSString stringWithFormat:@"%@%@", AKTopicBrowserPathSeparator,
            [self stringToDisplayInTopicBrowser]];
}

- (NSArray *)childTopics
{
    NSMutableArray *columnValues = [NSMutableArray array];

    if ([_topicDatabase functionsGroupsForFrameworkNamed:_topicFrameworkName].count > 0)
    {
        [columnValues addObject:[AKFunctionsTopic topicWithFrameworkNamed:_topicFrameworkName
                                                               inDatabase:_topicDatabase]];
    }

    if ([_topicDatabase globalsGroupsForFrameworkNamed:_topicFrameworkName].count > 0)
    {
        [columnValues addObject:[AKGlobalsTopic topicWithFrameworkNamed:_topicFrameworkName
                                                             inDatabase:_topicDatabase]];
    }

    if ([_topicDatabase formalProtocolsForFrameworkNamed:_topicFrameworkName].count > 0)
    {
        [columnValues addObject:[AKFormalProtocolsTopic topicWithFrameworkNamed:_topicFrameworkName
                                                                     inDatabase:_topicDatabase]];
    }

    if ([_topicDatabase informalProtocolsForFrameworkNamed:_topicFrameworkName].count > 0)
    {
        [columnValues addObject:[AKInformalProtocolsTopic topicWithFrameworkNamed:_topicFrameworkName
                                                                       inDatabase:_topicDatabase]];
    }

    return columnValues;
}

#pragma mark -
#pragma mark AKPrefDictionary methods

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
    return [self topicWithFrameworkNamed:fwName inDatabase:db];
}

- (NSDictionary *)asPrefDictionary
{
    NSMutableDictionary *prefDict = [NSMutableDictionary dictionary];

    prefDict[AKTopicClassNamePrefKey] = self.className;
    prefDict[AKFrameworkNamePrefKey] = _topicFrameworkName;

    return prefDict;
}

@end
