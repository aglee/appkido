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

#import "AKAppDelegate.h"
#import "AKProtocolGeneralSubtopic.h"
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
    return [[[self alloc] initWithProtocolNode:protocolNode] autorelease];
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithProtocolNode:(AKProtocolNode *)protocolNode
{
    if ((self = [super init]))
    {
        _protocolNode = [protocolNode retain];
    }

    return self;
}

- (id)init
{
    DIGSLogError_NondesignatedInitializer();
    return nil;
}

- (void)dealloc
{
    [_protocolNode retain];

    [super dealloc];
}

#pragma mark -
#pragma mark AKTopic methods

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
            [_protocolNode nameOfOwningFramework], [_protocolNode nodeName]];
}

- (NSString *)pathInTopicBrowser
{
    NSString *whichProtocols = ([_protocolNode isInformal]
                                ? AKInformalProtocolsTopicName
                                : AKProtocolsTopicName);

    return [NSString stringWithFormat:@"%@%@%@%@%@<%@>",
            AKTopicBrowserPathSeparator, [_protocolNode nameOfOwningFramework],
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
    AKProtocolGeneralSubtopic *generalSubtopic;
    generalSubtopic = [AKProtocolGeneralSubtopic subtopicForProtocolNode:_protocolNode];

    AKPropertiesSubtopic *propertiesSubtopic;
    propertiesSubtopic = [AKPropertiesSubtopic subtopicForBehaviorNode:_protocolNode
                                                     includeAncestors:NO];
    AKPropertiesSubtopic *allPropertiesSubtopic;
    allPropertiesSubtopic = [AKPropertiesSubtopic subtopicForBehaviorNode:_protocolNode
                                                         includeAncestors:YES];
    AKClassMethodsSubtopic *classMethodsSubtopic;
    classMethodsSubtopic = [AKClassMethodsSubtopic subtopicForBehaviorNode:_protocolNode
                                                          includeAncestors:NO];
    AKClassMethodsSubtopic *allClassMethodsSubtopic;
    allClassMethodsSubtopic = [AKClassMethodsSubtopic subtopicForBehaviorNode:_protocolNode
                                                             includeAncestors:YES];
    AKInstanceMethodsSubtopic *instMethodsSubtopic;
    instMethodsSubtopic = [AKInstanceMethodsSubtopic subtopicForBehaviorNode:_protocolNode
                                                            includeAncestors:NO];
    AKInstanceMethodsSubtopic *allInstanceMethodsSubtopic;
    allInstanceMethodsSubtopic = [AKInstanceMethodsSubtopic subtopicForBehaviorNode:_protocolNode
                                                                   includeAncestors:YES];
    AKDelegateMethodsSubtopic *delegateMethodsSubtopic;
    delegateMethodsSubtopic = [AKDelegateMethodsSubtopic subtopicForClassNode:nil
                                                             includeAncestors:NO];
    AKDelegateMethodsSubtopic *allDelegateMethodsSubtopic;
    allDelegateMethodsSubtopic = [AKDelegateMethodsSubtopic subtopicForClassNode:nil
                                                                includeAncestors:YES];
    AKNotificationsSubtopic *notificationsSubtopic;
    notificationsSubtopic = [AKNotificationsSubtopic subtopicForClassNode:nil
                                                         includeAncestors:NO];
    AKNotificationsSubtopic *allNotificationsSubtopic;
    allNotificationsSubtopic = [AKNotificationsSubtopic subtopicForClassNode:nil
                                                            includeAncestors:YES];
    return (@[
            generalSubtopic,
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
            ]);
}

#pragma mark -
#pragma mark AKPrefDictionary methods

+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict
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

@end
