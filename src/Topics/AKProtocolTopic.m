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

+ (instancetype)topicWithProtocolNode:(AKProtocolNode *)protocolNode
{
    return [[self alloc] initWithProtocolNode:protocolNode];
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithProtocolNode:(AKProtocolNode *)protocolNode
{
    if ((self = [super init]))
    {
        _protocolNode = protocolNode;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithProtocolNode:nil];
}


#pragma mark -
#pragma mark AKTopic methods

- (NSString *)stringToDisplayInTopicBrowser
{
    return [NSString stringWithFormat:@"<%@>", _protocolNode.nodeName];
}

- (NSString *)stringToDisplayInDescriptionField
{
    NSString *stringFormat = (_protocolNode.isInformal
                              ? @"%@ INFORMAL protocol <%@>"
                              : @"%@ protocol <%@>");

    return [NSString stringWithFormat:stringFormat,
            _protocolNode.nameOfOwningFramework, _protocolNode.nodeName];
}

- (NSString *)pathInTopicBrowser
{
    NSString *whichProtocols = (_protocolNode.isInformal
                                ? AKInformalProtocolsTopicName
                                : AKProtocolsTopicName);

    return [NSString stringWithFormat:@"%@%@%@%@%@<%@>",
            AKTopicBrowserPathSeparator, _protocolNode.nameOfOwningFramework,
            AKTopicBrowserPathSeparator, whichProtocols,
            AKTopicBrowserPathSeparator, _protocolNode.nodeName];
}

- (BOOL)browserCellHasChildren
{
    return NO;
}

#pragma mark -
#pragma mark AKBehaviorTopic methods

- (NSString *)behaviorName
{
    return _protocolNode.nodeName;
}

- (AKDocSetTokenItem *)topicNode
{
    return _protocolNode;
}

- (void)populateSubtopicsArray:(NSMutableArray *)array
{
    [array setArray:(@[
                     [AKProtocolGeneralSubtopic subtopicForProtocolNode:_protocolNode],
                     [AKPropertiesSubtopic subtopicForBehaviorItem:_protocolNode includeAncestors:NO],
                     [AKPropertiesSubtopic subtopicForBehaviorItem:_protocolNode includeAncestors:YES],
                     [AKClassMethodsSubtopic subtopicForBehaviorItem:_protocolNode includeAncestors:NO],
                     [AKClassMethodsSubtopic subtopicForBehaviorItem:_protocolNode includeAncestors:YES],
                     [AKInstanceMethodsSubtopic subtopicForBehaviorItem:_protocolNode includeAncestors:NO],
                     [AKInstanceMethodsSubtopic subtopicForBehaviorItem:_protocolNode includeAncestors:YES],
                     [AKDelegateMethodsSubtopic subtopicForClassNode:nil includeAncestors:NO],
                     [AKDelegateMethodsSubtopic subtopicForClassNode:nil includeAncestors:YES],
                     [AKNotificationsSubtopic subtopicForClassNode:nil includeAncestors:NO],
                     [AKNotificationsSubtopic subtopicForClassNode:nil includeAncestors:YES],
                     ])];
}

#pragma mark -
#pragma mark AKPrefDictionary methods

+ (instancetype)fromPrefDictionary:(NSDictionary *)prefDict
{
    if (prefDict == nil)
    {
        return nil;
    }

    NSString *protocolName = prefDict[AKBehaviorNamePrefKey];

    if (protocolName == nil)
    {
        DIGSLogWarning(@"malformed pref dictionary for class %@", [self className]);
        return nil;
    }
    else
    {
        AKDatabase *db = [(AKAppDelegate *)NSApp.delegate appDatabase];
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
