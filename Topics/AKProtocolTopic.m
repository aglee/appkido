/*
 * AKProtocolTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKProtocolTopic.h"
#import "DIGSLog.h"
#import "AKAppDelegate.h"
#import "AKBehaviorHeaderFile.h"
#import "AKDatabase.h"
#import "AKFrameworkConstants.h"
#import "AKProtocolToken.h"
#import "AKSubtopic.h"
#import "AKSubtopicConstants.h"

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
    return [NSString stringWithFormat:@"<%@>", _protocolToken.name];
}

- (NSString *)stringToDisplayInDescriptionField
{
    NSString *stringFormat = (_protocolToken.isInformal
                              ? @"%@ INFORMAL protocol <%@>"
                              : @"%@ protocol <%@>");

    return [NSString stringWithFormat:stringFormat,
            _protocolToken.frameworkName, _protocolToken.name];
}

- (NSString *)pathInTopicBrowser
{
    NSString *whichProtocols = (_protocolToken.isInformal
                                ? AKInformalProtocolsTopicName
                                : AKProtocolsTopicName);

    return [NSString stringWithFormat:@"%@%@%@%@%@<%@>",
            AKTopicBrowserPathSeparator, _protocolToken.frameworkName,
            AKTopicBrowserPathSeparator, whichProtocols,
            AKTopicBrowserPathSeparator, _protocolToken.name];
}

- (BOOL)browserCellHasChildren
{
    return NO;
}

#pragma mark - AKBehaviorTopic methods

- (NSString *)behaviorName
{
    return _protocolToken.name;
}

- (AKToken *)topicToken
{
    return _protocolToken;
}

- (void)populateSubtopicsArray:(NSMutableArray *)array
{
    [array setArray:[self subtopicsArray]];
}

- (NSArray *)subtopicsArray
{
    return @[
             [self _generalSubtopic],
             [[AKSubtopic alloc] initWithName:AKPropertiesSubtopicName
                                 docListItems:_protocolToken.propertyTokens],
             [[AKSubtopic alloc] initWithName:AKClassMethodsSubtopicName
                                 docListItems:_protocolToken.classMethodTokens],
             [[AKSubtopic alloc] initWithName:AKInstanceMethodsSubtopicName
                                 docListItems:_protocolToken.instanceMethodTokens],

             // These subtopics are added to the list even though they don't
             // apply to protocols, only classes.  This way, if, say, "Bindings"
             // is selected, and the user navigates from a class to a protocol
             // and then to a class, the "Bindings" subtopic stays selected
             // because it was always on the list.  The idea is to keep as much
             // as possible the same as the user navigates around.
             //
             //TODO: Revisit this.  I'm thinking maybe this makes it look like
             // protocols can have bindings, etc. (or that I *think* they can),
             // when they can't.  One option would be to have a doc list with
             // just one item with a name like "(not applicable)" or something.
             //
             //TODO: Revisit the "ALL Instance Methods" etc. feature.
//             [[AKSubtopic alloc] initWithName:AKDelegateMethodsSubtopicName
//                                 docListItems:nil],
//             [[AKSubtopic alloc] initWithName:AKNotificationsSubtopicName
//                                 docListItems:nil],
//             [[AKSubtopic alloc] initWithName:AKBindingsSubtopicName
//                                 docListItems:nil],
             ];
}

- (AKSubtopic *)_generalSubtopic
{
    AKBehaviorHeaderFile *headerFileDoc = [[AKBehaviorHeaderFile alloc] initWithBehaviorToken:_protocolToken];

    NSArray *docListItems = @[
                              headerFileDoc
                              ];

    return [[AKSubtopic alloc] initWithName:AKGeneralSubtopicName
                               docListItems:docListItems];
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
