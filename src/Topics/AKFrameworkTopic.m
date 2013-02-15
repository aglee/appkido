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
#import "AKFramework.h"
#import "AKAppController.h"
#import "AKFormalProtocolsTopic.h"
#import "AKInformalProtocolsTopic.h"
#import "AKFunctionsTopic.h"
#import "AKGlobalsTopic.h"

@implementation AKFrameworkTopic


#pragma mark -
#pragma mark Factory methods

+ (AKFrameworkTopic *)topicWithFrameworkNamed:(NSString *)frameworkName inDatabase:(AKDatabase *)database
{
    return [[[self alloc] initWithFrameworkNamed:frameworkName inDatabase:database] autorelease];
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithFrameworkNamed:(NSString *)frameworkName inDatabase:(AKDatabase *)aDatabase
{
    if ((self = [super init]))
    {
        _topicFramework = [[aDatabase frameworkWithName:frameworkName] retain];
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    [self release];
    return nil;
}

- (void)dealloc
{
    [_topicFramework release];

    [super dealloc];
}


#pragma mark -
#pragma mark AKTopic methods

+ (AKTopic *)fromPrefDictionary:(NSDictionary *)prefDict
{
    if (prefDict == nil)
    {
        return nil;
    }

    // Get the framework name.
    NSString *fwName = [prefDict objectForKey:AKFrameworkNamePrefKey];

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

    AKDatabase *db = [[NSApp delegate] appDatabase];
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

    [prefDict setObject:[self className] forKey:AKTopicClassNamePrefKey];
    [prefDict setObject:[_topicFramework frameworkName] forKey:AKFrameworkNamePrefKey];

    return prefDict;
}

- (NSString *)stringToDisplayInTopicBrowser
{
    return [_topicFramework frameworkName];
}

- (NSString *)pathInTopicBrowser
{
    return [NSString stringWithFormat:@"%@%@", AKTopicBrowserPathSeparator, [self stringToDisplayInTopicBrowser]];
}

- (NSArray *)childTopics
{
    NSMutableArray *columnValues = [NSMutableArray array];
    AKDatabase *aDatabase = [_topicFramework fwDatabase];
    NSString *frameworkName = [_topicFramework frameworkName];

    if ([aDatabase numberOfFunctionsGroupsForFrameworkNamed:frameworkName] > 0)
    {
        [columnValues addObject:[AKFunctionsTopic topicWithFrameworkNamed:frameworkName inDatabase:aDatabase]];
    }

    if ([aDatabase numberOfGlobalsGroupsForFrameworkNamed:frameworkName] > 0)
    {
        [columnValues addObject:[AKGlobalsTopic topicWithFrameworkNamed:frameworkName inDatabase:aDatabase]];
    }

    if ([[aDatabase formalProtocolsForFrameworkNamed:frameworkName] count] > 0)
    {
        [columnValues addObject:[AKFormalProtocolsTopic topicWithFrameworkNamed:frameworkName inDatabase:aDatabase]];
    }

    if ([[aDatabase informalProtocolsForFrameworkNamed:frameworkName] count] > 0)
    {
        [columnValues addObject:[AKInformalProtocolsTopic topicWithFrameworkNamed:frameworkName inDatabase:aDatabase]];
    }

    return columnValues;
}

@end
