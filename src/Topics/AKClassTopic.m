/*
 * AKClassTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKClassTopic.h"

#import "DIGSLog.h"

#import "AKAppDelegate.h"
#import "AKClassMethodsSubtopic.h"
#import "AKClassGeneralSubtopic.h"
#import "AKClassItem.h"
#import "AKDatabase.h"
#import "AKDelegateMethodsSubtopic.h"
#import "AKInstanceMethodsSubtopic.h"
#import "AKNotificationsSubtopic.h"
#import "AKPropertiesSubtopic.h"
#import "AKSortUtils.h"

@implementation AKClassTopic

#pragma mark -
#pragma mark Factory methods

+ (instancetype)topicWithClassItem:(AKClassItem *)classItem
{
    return [[self alloc] initWithClassItem:classItem];
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (instancetype)initWithClassItem:(AKClassItem *)classItem
{
    if ((self = [super init]))
    {
        _classItem = classItem;
    }

    return self;
}

- (instancetype)init
{
    DIGSLogError_NondesignatedInitializer();
    return [self initWithClassItem:nil];
}


#pragma mark -
#pragma mark AKTopic methods

- (AKClassItem *)parentClassOfTopic
{
    return _classItem.parentClass;
}

- (NSString *)stringToDisplayInTopicBrowser
{
    return _classItem.nodeName;
}

- (NSString *)stringToDisplayInDescriptionField
{
    return [NSString stringWithFormat:@"%@ class %@",
            _classItem.nameOfOwningFramework, _classItem.nodeName];
}

- (NSString *)pathInTopicBrowser
{
    if (_classItem == nil)
    {
        return nil;
    }

    NSString *path = [AKTopicBrowserPathSeparator stringByAppendingString:_classItem.nodeName];
    AKClassItem *superNode = _classItem;

    while ((superNode = superNode.parentClass))
    {
        path = [AKTopicBrowserPathSeparator stringByAppendingString:
                [superNode.nodeName stringByAppendingString:path]];
    }

    return path;
}

- (BOOL)browserCellHasChildren
{
    return [_classItem hasChildClasses];
}

- (NSArray *)childTopics
{
    NSMutableArray *columnValues = [NSMutableArray array];

    for (AKClassItem *subclassItem in [AKSortUtils arrayBySortingArray:[_classItem childClasses]])
    {
        [columnValues addObject:[AKClassTopic topicWithClassItem:subclassItem]];
    }

    return columnValues;
}

#pragma mark -
#pragma mark AKBehaviorTopic methods

- (NSString *)behaviorName
{
    return _classItem.nodeName;
}

- (AKDocSetTokenItem *)topicNode
{
    return _classItem;
}

- (void)populateSubtopicsArray:(NSMutableArray *)array
{
    [array setArray:(@[
                     [AKClassGeneralSubtopic subtopicForClassItem:_classItem],
                     [AKPropertiesSubtopic subtopicForBehaviorItem:_classItem includeAncestors:NO],
                     [AKPropertiesSubtopic subtopicForBehaviorItem:_classItem includeAncestors:YES],
                     [AKClassMethodsSubtopic subtopicForBehaviorItem:_classItem includeAncestors:NO],
                     [AKClassMethodsSubtopic subtopicForBehaviorItem:_classItem includeAncestors:YES],
                     [AKInstanceMethodsSubtopic subtopicForBehaviorItem:_classItem includeAncestors:NO],
                     [AKInstanceMethodsSubtopic subtopicForBehaviorItem:_classItem includeAncestors:YES],
                     [AKDelegateMethodsSubtopic subtopicForClassItem:_classItem includeAncestors:NO],
                     [AKDelegateMethodsSubtopic subtopicForClassItem:_classItem includeAncestors:YES],
                     [AKNotificationsSubtopic subtopicForClassItem:_classItem includeAncestors:NO],
                     [AKNotificationsSubtopic subtopicForClassItem:_classItem includeAncestors:YES],
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

    NSString *className = prefDict[AKBehaviorNamePrefKey];

    if (className == nil)
    {
        DIGSLogWarning(@"malformed pref dictionary for class %@", [self className]);
        return nil;
    }
    else
    {
        AKDatabase *db = [(AKAppDelegate *)NSApp.delegate appDatabase];
        AKClassItem *classItem = [db classWithName:className];

        if (!classItem)
        {
            DIGSLogInfo(@"couldn't find a class in the database named %@", className);
            return nil;
        }

        return [self topicWithClassItem:classItem];
    }
}

@end
