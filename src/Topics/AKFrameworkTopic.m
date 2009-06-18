/*
 * AKFrameworkTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKFrameworkTopic.h"

#import "DIGSLog.h"
#import "AKPrefConstants.h"
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

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (AKFrameworkTopic *)topicWithFrameworkNamed:(NSString *)frameworkName inDatabase:(AKDatabase *)database
{
    return [[[self alloc] initWithFrameworkNamed:frameworkName inDatabase:database] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithFrameworkNamed:(NSString *)frameworkName inDatabase:(AKDatabase *)database
{
    if ((self = [super initWithDatabase:database]))
    {
        _topicFramework = [[_database frameworkWithName:frameworkName] retain];
    }

    return self;
}

- (id)initWithDatabase:(AKDatabase *)database
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

//-------------------------------------------------------------------------
// AKTopic methods
//-------------------------------------------------------------------------

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
    [prefDict setObject:_topicFramework forKey:AKFrameworkNamePrefKey];

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
    NSString *frameworkName = [_topicFramework frameworkName];

    if ([_database numberOfFunctionsGroupsForFrameworkNamed:frameworkName] > 0)
    {
        [columnValues addObject:[AKFunctionsTopic topicWithFrameworkNamed:frameworkName inDatabase:_database]];
    }

    if ([_database numberOfGlobalsGroupsForFrameworkNamed:frameworkName] > 0)
    {
        [columnValues addObject:[AKGlobalsTopic topicWithFrameworkNamed:frameworkName inDatabase:_database]];
    }

    if ([[_database formalProtocolsForFrameworkNamed:frameworkName] count] > 0)
    {
        [columnValues addObject:[AKFormalProtocolsTopic topicWithFrameworkNamed:frameworkName inDatabase:_database]];
    }

    if ([[_database informalProtocolsForFrameworkNamed:frameworkName] count] > 0)
    {
        [columnValues addObject:[AKInformalProtocolsTopic topicWithFrameworkNamed:frameworkName inDatabase:_database]];
    }

    return columnValues;
}

@end
