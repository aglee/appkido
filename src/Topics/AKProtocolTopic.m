/*
 * AKProtocolTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKProtocolTopic.h"

#import "DIGSLog.h"

#import "AKFrameworkConstants.h"
#import "AKDatabase.h"
#import "AKProtocolNode.h"

#import "AKProtocolOverviewSubtopic.h"
#import "AKPropertiesSubtopic.h"
#import "AKClassMethodsSubtopic.h"
#import "AKInstanceMethodsSubtopic.h"
#import "AKDelegateMethodsSubtopic.h"
#import "AKNotificationsSubtopic.h"

@implementation AKProtocolTopic

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)topicWithProtocolNode:(AKProtocolNode *)protocolNode
    inDatabase:(AKDatabase *)database
{
    return [[[self alloc] initWithProtocolNode:protocolNode inDatabase:database] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

- (id)initWithProtocolNode:(AKProtocolNode *)protocolNode
    inDatabase:(AKDatabase *)database
{
    if ((self = [super initWithDatabase:database]))
    {
        _protocolNode = [protocolNode retain];
    }

    return self;
}

- (id)initWithDatabase:(AKDatabase *)database
{
    DIGSLogNondesignatedInitializer();
    [self release];
    return nil;
}

- (void)dealloc
{
    [_protocolNode release];

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

    NSString *protocolName =
        [prefDict objectForKey:AKBehaviorNamePrefKey];

    if (protocolName == nil)
    {
        DIGSLogWarning(
            @"malformed pref dictionary for class %@",
            [self className]);
        return nil;
    }
    else
    {
        NSString *platformName = [prefDict objectForKey:AKPlatformNamePrefKey];

        if (platformName == nil)
        {
            platformName = AKMacOSPlatform;
        }

        AKDatabase *db = [AKDatabase databaseForPlatform:platformName];
        AKProtocolNode *protocolNode = [db protocolWithName:protocolName];

        if (!protocolNode)
        {
            DIGSLogInfo(
                @"couldn't find a protocol in the database named %@",
                protocolName);
            return nil;
        }

        return [self topicWithProtocolNode:protocolNode inDatabase:db];
    }
}

- (NSString *)stringToDisplayInTopicBrowser
{
    return [NSString stringWithFormat:@"<%@>", [_protocolNode nodeName]];
}

- (NSString *)stringToDisplayInDescriptionField
{
    NSString *stringFormat =
        [_protocolNode isInformal]
        ? @"%@ INFORMAL protocol <%@>"
        : @"%@ protocol <%@>";

    return
        [NSString stringWithFormat:stringFormat,
            [_protocolNode owningFramework], [_protocolNode nodeName]];
}

- (NSString *)pathInTopicBrowser
{
    NSString *whichProtocols =
        [_protocolNode isInformal]
        ? AKInformalProtocolsTopicName
        : AKProtocolsTopicName;

    return
        [NSString stringWithFormat:@"%@%@%@%@%@<%@>",
            AKTopicBrowserPathSeparator, [_protocolNode owningFramework],
            AKTopicBrowserPathSeparator, whichProtocols,
            AKTopicBrowserPathSeparator, [_protocolNode nodeName]];
}

- (BOOL)browserCellHasChildren
{
    return NO;
}

//-------------------------------------------------------------------------
// AKBehaviorTopic methods
//-------------------------------------------------------------------------

- (NSString *)behaviorName
{
    return [_protocolNode nodeName];
}

- (AKDatabaseNode *)topicNode
{
    return _protocolNode;
}

- (NSArray *)createSubtopicsArray
{
    AKProtocolOverviewSubtopic *overviewSubtopic =
        [AKProtocolOverviewSubtopic subtopicForProtocolNode:_protocolNode];

    AKPropertiesSubtopic *propertiesSubtopic =
        [AKPropertiesSubtopic
            subtopicForBehaviorNode:_protocolNode
            includeAncestors:NO];
    AKPropertiesSubtopic *allPropertiesSubtopic =
        [AKPropertiesSubtopic
            subtopicForBehaviorNode:_protocolNode
            includeAncestors:YES];

    AKClassMethodsSubtopic *classMethodsSubtopic =
        [AKClassMethodsSubtopic
            subtopicForBehaviorNode:_protocolNode
            includeAncestors:NO];
    AKClassMethodsSubtopic *allClassMethodsSubtopic =
        [AKClassMethodsSubtopic
            subtopicForBehaviorNode:_protocolNode
            includeAncestors:YES];

    AKInstanceMethodsSubtopic *instMethodsSubtopic =
        [AKInstanceMethodsSubtopic
            subtopicForBehaviorNode:_protocolNode
            includeAncestors:NO];
    AKInstanceMethodsSubtopic *allInstanceMethodsSubtopic =
        [AKInstanceMethodsSubtopic
            subtopicForBehaviorNode:_protocolNode
            includeAncestors:YES];

    AKDelegateMethodsSubtopic *delegateMethodsSubtopic =
        [AKDelegateMethodsSubtopic
            subtopicForClassNode:nil
            includeAncestors:NO];
    AKDelegateMethodsSubtopic *allDelegateMethodsSubtopic =
        [AKDelegateMethodsSubtopic
            subtopicForClassNode:nil
            includeAncestors:YES];

    AKNotificationsSubtopic *notificationsSubtopic =
        [AKNotificationsSubtopic
            subtopicForClassNode:nil
            includeAncestors:NO];
    AKNotificationsSubtopic *allNotificationsSubtopic =
        [AKNotificationsSubtopic
            subtopicForClassNode:nil
            includeAncestors:YES];

    return
        [NSArray arrayWithObjects:
            overviewSubtopic,
            propertiesSubtopic,
                allPropertiesSubtopic,
            classMethodsSubtopic,
                allClassMethodsSubtopic,
            instMethodsSubtopic,
                allInstanceMethodsSubtopic,
            delegateMethodsSubtopic,
                allDelegateMethodsSubtopic,
            notificationsSubtopic,
                allNotificationsSubtopic,
            nil];
}

@end
