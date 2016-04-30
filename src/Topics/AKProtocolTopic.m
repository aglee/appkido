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
#import "AKProtocolItem.h"

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

+ (instancetype)topicWithProtocolItem:(AKProtocolItem *)protocolItem
{
    return [[self alloc] initWithProtocolItem:protocolItem];
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithProtocolItem:(AKProtocolItem *)protocolItem
{
    if ((self = [super init]))
    {
        _protocolItem = protocolItem;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithProtocolItem:nil];
}


#pragma mark -
#pragma mark AKTopic methods

- (NSString *)stringToDisplayInTopicBrowser
{
    return [NSString stringWithFormat:@"<%@>", _protocolItem.nodeName];
}

- (NSString *)stringToDisplayInDescriptionField
{
    NSString *stringFormat = (_protocolItem.isInformal
                              ? @"%@ INFORMAL protocol <%@>"
                              : @"%@ protocol <%@>");

    return [NSString stringWithFormat:stringFormat,
            _protocolItem.nameOfOwningFramework, _protocolItem.nodeName];
}

- (NSString *)pathInTopicBrowser
{
    NSString *whichProtocols = (_protocolItem.isInformal
                                ? AKInformalProtocolsTopicName
                                : AKProtocolsTopicName);

    return [NSString stringWithFormat:@"%@%@%@%@%@<%@>",
            AKTopicBrowserPathSeparator, _protocolItem.nameOfOwningFramework,
            AKTopicBrowserPathSeparator, whichProtocols,
            AKTopicBrowserPathSeparator, _protocolItem.nodeName];
}

- (BOOL)browserCellHasChildren
{
    return NO;
}

#pragma mark -
#pragma mark AKBehaviorTopic methods

- (NSString *)behaviorName
{
    return _protocolItem.nodeName;
}

- (AKTokenItem *)topicNode
{
    return _protocolItem;
}

- (void)populateSubtopicsArray:(NSMutableArray *)array
{
    [array setArray:(@[
                     [AKProtocolGeneralSubtopic subtopicForProtocolItem:_protocolItem],
                     [AKPropertiesSubtopic subtopicForBehaviorItem:_protocolItem includeAncestors:NO],
                     [AKPropertiesSubtopic subtopicForBehaviorItem:_protocolItem includeAncestors:YES],
                     [AKClassMethodsSubtopic subtopicForBehaviorItem:_protocolItem includeAncestors:NO],
                     [AKClassMethodsSubtopic subtopicForBehaviorItem:_protocolItem includeAncestors:YES],
                     [AKInstanceMethodsSubtopic subtopicForBehaviorItem:_protocolItem includeAncestors:NO],
                     [AKInstanceMethodsSubtopic subtopicForBehaviorItem:_protocolItem includeAncestors:YES],
                     [AKDelegateMethodsSubtopic subtopicForClassItem:nil includeAncestors:NO],
                     [AKDelegateMethodsSubtopic subtopicForClassItem:nil includeAncestors:YES],
                     [AKNotificationsSubtopic subtopicForClassItem:nil includeAncestors:NO],
                     [AKNotificationsSubtopic subtopicForClassItem:nil includeAncestors:YES],
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
        AKProtocolItem *protocolItem = [db protocolWithName:protocolName];

        if (!protocolItem)
        {
            DIGSLogInfo(@"couldn't find a protocol in the database named %@", protocolName);
            return nil;
        }

        return [self topicWithProtocolItem:protocolItem];
    }
}

@end
