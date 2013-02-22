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

#import "AKAppController.h"
#import "AKProtocolOverviewSubtopic.h"
#import "AKPropertiesSubtopic.h"
#import "AKClassMethodsSubtopic.h"
#import "AKInstanceMethodsSubtopic.h"
#import "AKDelegateMethodsSubtopic.h"
#import "AKNotificationsSubtopic.h"

@implementation AKProtocolTopic


#pragma mark -
#pragma mark Factory methods

+ (id)topicWithProtocolNode:(AKProtocolNode *)protocolNode
{
    return [[self alloc] initWithProtocolNode:protocolNode];
}


#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithProtocolNode:(AKProtocolNode *)protocolNode
{
    if ((self = [super init]))
    {
        _protocolNode = protocolNode;
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}



#pragma mark -
#pragma mark AKTopic methods

+ (AKTopic *)fromPrefDictionary:(NSDictionary *)prefDict
{
    if (prefDict == nil)
    {
        return nil;
    }

    NSString *protocolName = [prefDict objectForKey:AKBehaviorNamePrefKey];

    if (protocolName == nil)
    {
        DIGSLogWarning(@"malformed pref dictionary for class %@", [self className]);
        return nil;
    }
    else
    {
        AKDatabase *db = [[NSApp delegate] appDatabase];
        AKProtocolNode *protocolNode = [db protocolWithName:protocolName];

        if (!protocolNode)
        {
            DIGSLogInfo(@"couldn't find a protocol in the database named %@", protocolName);
            return nil;
        }

        return [self topicWithProtocolNode:protocolNode];
    }
}

- (NSString *)stringToDisplayInTopicBrowser
{
    return [NSString stringWithFormat:@"<%@>", [_protocolNode nodeName]];
}

- (NSString *)stringToDisplayInDescriptionField
{
    NSString *stringFormat = ([_protocolNode isInformal]
                              ? @"%@ INFORMAL protocol <%@>"
                              : @"%@ protocol <%@>");

    return [NSString stringWithFormat:stringFormat,
            [_protocolNode owningFrameworkName], [_protocolNode nodeName]];
}

- (NSString *)pathInTopicBrowser
{
    NSString *whichProtocols = ([_protocolNode isInformal]
                                ? AKInformalProtocolsTopicName
                                : AKProtocolsTopicName);

    return [NSString stringWithFormat:@"%@%@%@%@%@<%@>",
            AKTopicBrowserPathSeparator, [_protocolNode owningFrameworkName],
            AKTopicBrowserPathSeparator, whichProtocols,
            AKTopicBrowserPathSeparator, [_protocolNode nodeName]];
}

- (BOOL)browserCellHasChildren
{
    return NO;
}


#pragma mark -
#pragma mark AKBehaviorTopic methods

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
