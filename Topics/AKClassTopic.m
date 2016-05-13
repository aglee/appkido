/*
 * AKClassTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKClassTopic.h"
#import "DIGSLog.h"
#import "AKAppDelegate.h"
#import "AKBindingsSubtopic.h"
#import "AKClassMethodsSubtopic.h"
#import "AKClassGeneralSubtopic.h"
#import "AKClassToken.h"
#import "AKDatabase.h"
#import "AKDelegateMethodsSubtopic.h"
#import "AKInstanceMethodsSubtopic.h"
#import "AKNotificationsSubtopic.h"
#import "AKPropertiesSubtopic.h"
#import "AKSortUtils.h"

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
    return _classToken.tokenName;
}

- (NSString *)stringToDisplayInDescriptionField
{
    return [NSString stringWithFormat:@"%@ class %@",
            _classToken.frameworkName, _classToken.tokenName];
}

- (NSString *)pathInTopicBrowser
{
    if (_classToken == nil)
    {
        return nil;
    }

    NSString *path = [AKTopicBrowserPathSeparator stringByAppendingString:_classToken.tokenName];
    AKClassToken *superItem = _classToken;

    while ((superItem = superItem.parentClass))
    {
        path = [AKTopicBrowserPathSeparator stringByAppendingString:
                [superItem.tokenName stringByAppendingString:path]];
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
    return _classToken.tokenName;
}

- (AKToken *)topicItem
{
    return _classToken;
}

- (void)populateSubtopicsArray:(NSMutableArray *)array
{
    [array setArray:(@[
                     [AKClassGeneralSubtopic subtopicForClassToken:_classToken],
                     [AKPropertiesSubtopic subtopicForBehaviorToken:_classToken includeAncestors:NO],
//                     [AKPropertiesSubtopic subtopicForBehaviorToken:_classToken includeAncestors:YES],
                     [AKClassMethodsSubtopic subtopicForBehaviorToken:_classToken includeAncestors:NO],
//                     [AKClassMethodsSubtopic subtopicForBehaviorToken:_classToken includeAncestors:YES],
                     [AKInstanceMethodsSubtopic subtopicForBehaviorToken:_classToken includeAncestors:NO],
//                     [AKInstanceMethodsSubtopic subtopicForBehaviorToken:_classToken includeAncestors:YES],
                     [AKDelegateMethodsSubtopic subtopicForClassToken:_classToken includeAncestors:NO],
//                     [AKDelegateMethodsSubtopic subtopicForClassToken:_classToken includeAncestors:YES],
                     [AKNotificationsSubtopic subtopicForClassToken:_classToken includeAncestors:NO],
//                     [AKNotificationsSubtopic subtopicForClassToken:_classToken includeAncestors:YES],
                     [AKBindingsSubtopic subtopicForClassToken:_classToken includeAncestors:NO],
//                     [AKBindingsSubtopic subtopicForClassToken:_classToken includeAncestors:YES],
                     ])];
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
