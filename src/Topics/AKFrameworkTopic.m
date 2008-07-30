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

+ (AKFrameworkTopic *)topicWithFrameworkName:(NSString *)fwName
{
    return [[[self alloc] initWithFrameworkName:fwName] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithFrameworkName:(NSString *)fwName
{
    if ((self = [super init]))
    {
        _topicFramework = [fwName retain];
    }

    return self;
}

- (id)init
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

    // Get the framework name.  Note that in older versions of AppKiDo,
    // "AppKit" was saved as "ApplicationKit" in prefs.
    NSString *fwName = [prefDict objectForKey:AKFrameworkNamePrefKey];
    if ([fwName isEqualToString:@"ApplicationKit"])
    {
        fwName = AKAppKitFrameworkName;
    }

    if (fwName == nil)
    {
        DIGSLogWarning(
            @"malformed pref dictionary for class %@",
            [self className]);
        return nil;
    }

    // Get the framework.
    if (![[AKDatabase defaultDatabase] hasFrameworkWithName:fwName])
    {
        DIGSLogWarning(
            @"framework %@ named in pref dict for %@ doesn't exist",
            [self className], fwName);
        return nil;
    }

    // If we got this far, we have what we need to create an instance.
    return [self topicWithFrameworkName:fwName];
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
    AKDatabase *db = [AKDatabase defaultDatabase];
    NSMutableArray *columnValues = [NSMutableArray array];

    if ([db numberOfFunctionsGroupsForFramework:_topicFramework] > 0)
    {
        [columnValues
            addObject:[AKFunctionsTopic topicWithFrameworkName:_topicFramework]];
    }

    if ([db numberOfGlobalsGroupsForFramework:_topicFramework] > 0)
    {
        [columnValues
            addObject:[AKGlobalsTopic topicWithFrameworkName:_topicFramework]];
    }

    if ([[db formalProtocolsForFramework:_topicFramework] count] > 0)
    {
        [columnValues
            addObject:[AKFormalProtocolsTopic topicWithFrameworkName:_topicFramework]];
    }

    if ([[db informalProtocolsForFramework:_topicFramework] count] > 0)
    {
        [columnValues
            addObject:[AKInformalProtocolsTopic topicWithFrameworkName:_topicFramework]];
    }

    return columnValues;
}

@end
