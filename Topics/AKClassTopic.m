/*
 * AKClassTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKClassTopic.h"
#import "DIGSLog.h"
#import "AKAppDelegate.h"
#import "AKBehaviorHeaderFile.h"
#import "AKClassToken.h"
#import "AKDatabase.h"
#import "AKSortUtils.h"
#import "AKSubtopic.h"
#import "AKSubtopicConstants.h"

@implementation AKClassTopic

#pragma mark - Factory methods

+ (instancetype)topicWithClassToken:(AKClassToken *)classToken
{
    return [[self alloc] initWithClassToken:classToken];
}

#pragma mark - Init/awake/dealloc

- (instancetype)initWithClassToken:(AKClassToken *)classToken
{
    if ((self = [super init]))
    {
        _classToken = classToken;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithClassToken:nil];
}

#pragma mark - AKTopic methods

- (AKClassToken *)parentClassOfTopic
{
    return _classToken.parentClass;
}

- (NSString *)stringToDisplayInTopicBrowser
{
    return _classToken.name;
}

- (NSString *)stringToDisplayInDescriptionField
{
    return [NSString stringWithFormat:@"%@ class %@",
            _classToken.frameworkName, _classToken.name];
}

- (NSString *)pathInTopicBrowser
{
    if (_classToken == nil)
    {
        return nil;
    }

    NSString *path = [AKTopicBrowserPathSeparator stringByAppendingString:_classToken.name];
    AKClassToken *classToken = _classToken;

    while ((classToken = classToken.parentClass))
    {
        path = [AKTopicBrowserPathSeparator stringByAppendingString:
                [classToken.name stringByAppendingString:path]];
    }

    return path;
}

- (BOOL)browserCellHasChildren
{
    return [_classToken hasChildClasses];
}

- (NSArray *)childTopics
{
    NSMutableArray *columnValues = [NSMutableArray array];

    for (AKClassToken *subclassToken in [AKSortUtils arrayBySortingArray:[_classToken childClasses]])
    {
        [columnValues addObject:[AKClassTopic topicWithClassToken:subclassToken]];
    }

    return columnValues;
}

#pragma mark - AKBehaviorTopic methods

- (NSString *)behaviorName
{
    return _classToken.name;
}

- (AKToken *)topicToken
{
    return _classToken;
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
                                 docListItems:_classToken.propertyTokens],
             [[AKSubtopic alloc] initWithName:AKClassMethodsSubtopicName
                                 docListItems:_classToken.classMethodTokens],
             [[AKSubtopic alloc] initWithName:AKInstanceMethodsSubtopicName
                                 docListItems:_classToken.instanceMethodTokens],
             [[AKSubtopic alloc] initWithName:AKDelegateMethodsSubtopicName
                                 docListItems:_classToken.documentedDelegateMethods],
             [[AKSubtopic alloc] initWithName:AKNotificationsSubtopicName
                                 docListItems:_classToken.documentedNotifications],
             [[AKSubtopic alloc] initWithName:AKBindingsSubtopicName
                                 docListItems:_classToken.documentedBindings],
             ];
}

- (AKSubtopic *)_generalSubtopic
{
    AKBehaviorHeaderFile *headerFileDoc = [[AKBehaviorHeaderFile alloc] initWithBehaviorToken:_classToken];

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

    NSString *className = prefDict[AKBehaviorNamePrefKey];

    if (className == nil)
    {
        DIGSLogWarning(@"malformed pref dictionary for class %@", [self className]);
        return nil;
    }
    else
    {
        AKDatabase *db = [(AKAppDelegate *)NSApp.delegate appDatabase];
        AKClassToken *classToken = [db classWithName:className];

        if (!classToken)
        {
            DIGSLogInfo(@"couldn't find a class in the database named %@", className);
            return nil;
        }

        return [self topicWithClassToken:classToken];
    }
}

@end
