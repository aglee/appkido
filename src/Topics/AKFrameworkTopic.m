/*
 * AKFrameworkTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFrameworkTopic.h"

#import <DIGSLog.h>
#import "AKPrefConstants.h"
#import "AKFrameworkConstants.h"
#import "AKSortUtils.h"
#import "AKDatabase.h"
#import "AKFormalProtocolsTopic.h"
#import "AKInformalProtocolsTopic.h"
#import "AKFunctionsTopic.h"
#import "AKGlobalsTopic.h"

@implementation AKFrameworkTopic

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (AKFrameworkTopic *)topicWithFramework:(NSString *)fwName
    inDatabase:(AKDatabase *)database
{
    return [[[self alloc] initWithFramework:fwName inDatabase:database] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithFramework:(NSString *)fwName
    inDatabase:(AKDatabase *)database
{
    if ((self = [super initWithDatabase:database]))
    {
        _topicFramework = [fwName retain];
    }

    return self;
}

- (id)initWithDatabase:(AKDatabase *)database
{
    DIGSLogNondesignatedInitializer();
    [self dealloc];
    return nil;
}

- (void)dealloc
{
    [_topicFramework release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// AKTopic methods
//-------------------------------------------------------------------------

+ (AKTopic *)fromPrefDictionary:(NSDictionary *)prefDict
{
    if (prefDict == nil)
    {
        return nil;
    }

    // Get a database instance based on the platform name.
    NSString *platformName = [prefDict objectForKey:AKPlatformNamePrefKey];
    
    if (platformName == nil)
    {
        platformName = AKMacOSPlatform;
    }

    AKDatabase *db = [AKDatabase databaseForPlatform:platformName];

    // Get the framework name.
    NSString *fwName = [prefDict objectForKey:AKFrameworkNamePrefKey];

    if ([fwName isEqualToString:@"ApplicationKit"])
    {
        // In older versions of AppKiDo, "AppKit" was saved as "ApplicationKit" in prefs.
        fwName = AKAppKitFrameworkName;
    }

    if (fwName == nil)
    {
        DIGSLogWarning(
            @"malformed pref dictionary for class %@",
            [self className]);
        return nil;
    }

    if (![db hasFrameworkWithName:fwName])
    {
        DIGSLogWarning(
            @"framework %@ named in pref dict for %@ doesn't exist",
            [self className], fwName);
        return nil;
    }

    // If we got this far, we have what we need to create an instance.
    return [self topicWithFramework:fwName inDatabase:db];
}

- (NSDictionary *)asPrefDictionary
{
    NSMutableDictionary *prefDict = [NSMutableDictionary dictionary];

    [prefDict
        setObject:[self className]
        forKey:AKTopicClassNamePrefKey];

    [prefDict
        setObject:_topicFramework
        forKey:AKFrameworkNamePrefKey];

    return prefDict;
}

- (NSString *)stringToDisplayInTopicBrowser
{
    return _topicFramework;
}

- (NSString *)pathInTopicBrowser
{
    return
        [NSString stringWithFormat:@"%@%@",
            AKTopicBrowserPathSeparator,
            [self stringToDisplayInTopicBrowser]];
}

- (NSArray *)childTopics
{
    NSMutableArray *columnValues = [NSMutableArray array];

    if ([_database numberOfFunctionsGroupsForFramework:_topicFramework] > 0)
    {
        [columnValues
            addObject:[AKFunctionsTopic topicWithFramework:_topicFramework inDatabase:_database]];
    }

    if ([_database numberOfGlobalsGroupsForFramework:_topicFramework] > 0)
    {
        [columnValues
            addObject:[AKGlobalsTopic topicWithFramework:_topicFramework inDatabase:_database]];
    }

    if ([[_database formalProtocolsForFramework:_topicFramework] count] > 0)
    {
        [columnValues
            addObject:[AKFormalProtocolsTopic topicWithFramework:_topicFramework inDatabase:_database]];
    }

    if ([[_database informalProtocolsForFramework:_topicFramework] count] > 0)
    {
        [columnValues
            addObject:[AKInformalProtocolsTopic topicWithFramework:_topicFramework inDatabase:_database]];
    }

    return columnValues;
}

@end
