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
#import "AKProtocolToken.h"

#import "AKAppDelegate.h"
#import "AKProtocolGeneralSubtopic.h"
#import "AKPropertiesSubtopic.h"
#import "AKClassMethodsSubtopic.h"
#import "AKInstanceMethodsSubtopic.h"
#import "AKDelegateMethodsSubtopic.h"
#import "AKNotificationsSubtopic.h"

@implementation AKProtocolTopic

#pragma mark - Factory methods

+ (instancetype)topicWithProtocolToken:(AKProtocolToken *)protocolToken
{
    return [[self alloc] initWithProtocolToken:protocolToken];
}

#pragma mark - Init/awake/dealloc

- (instancetype)initWithProtocolToken:(AKProtocolToken *)protocolToken
{
    if ((self = [super init]))
    {
        _protocolToken = protocolToken;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithProtocolToken:nil];
}


#pragma mark - AKTopic methods

- (NSString *)stringToDisplayInTopicBrowser
{
    return [NSString stringWithFormat:@"<%@>", _protocolToken.tokenName];
}

- (NSString *)stringToDisplayInDescriptionField
{
    NSString *stringFormat = (_protocolToken.isInformal
                              ? @"%@ INFORMAL protocol <%@>"
                              : @"%@ protocol <%@>");

    return [NSString stringWithFormat:stringFormat,
            _protocolToken.frameworkName, _protocolToken.tokenName];
}

- (NSString *)pathInTopicBrowser
{
    NSString *whichProtocols = (_protocolToken.isInformal
                                ? AKInformalProtocolsTopicName
                                : AKProtocolsTopicName);

    return [NSString stringWithFormat:@"%@%@%@%@%@<%@>",
            AKTopicBrowserPathSeparator, _protocolToken.frameworkName,
            AKTopicBrowserPathSeparator, whichProtocols,
            AKTopicBrowserPathSeparator, _protocolToken.tokenName];
}

- (BOOL)browserCellHasChildren
{
    return NO;
}

#pragma mark - AKBehaviorTopic methods

- (NSString *)behaviorName
{
    return _protocolToken.tokenName;
}

- (AKToken *)topicItem
{
    return _protocolToken;
}

- (void)populateSubtopicsArray:(NSMutableArray *)array
{
    [array setArray:(@[
                     [AKProtocolGeneralSubtopic subtopicForProtocolToken:_protocolToken],
                     [AKPropertiesSubtopic subtopicForBehaviorToken:_protocolToken includeAncestors:NO],
//                     [AKPropertiesSubtopic subtopicForBehaviorToken:_protocolToken includeAncestors:YES],
                     [AKClassMethodsSubtopic subtopicForBehaviorToken:_protocolToken includeAncestors:NO],
//                     [AKClassMethodsSubtopic subtopicForBehaviorToken:_protocolToken includeAncestors:YES],
                     [AKInstanceMethodsSubtopic subtopicForBehaviorToken:_protocolToken includeAncestors:NO],
//                     [AKInstanceMethodsSubtopic subtopicForBehaviorToken:_protocolToken includeAncestors:YES],
                     [AKDelegateMethodsSubtopic subtopicForClassToken:nil includeAncestors:NO],
//                     [AKDelegateMethodsSubtopic subtopicForClassToken:nil includeAncestors:YES],
                     [AKNotificationsSubtopic subtopicForClassToken:nil includeAncestors:NO],
//                     [AKNotificationsSubtopic subtopicForClassToken:nil includeAncestors:YES],
                     ])];
}

#pragma mark - AKPrefDictionary methods

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
        AKProtocolToken *protocolToken = [db protocolWithName:protocolName];

        if (!protocolToken)
        {
            DIGSLogInfo(@"couldn't find a protocol in the database named %@", protocolName);
            return nil;
        }

        return [self topicWithProtocolToken:protocolToken];
    }
}

@end
