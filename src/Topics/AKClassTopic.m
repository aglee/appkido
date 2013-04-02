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
#import "AKClassNode.h"
#import "AKDatabase.h"
#import "AKDelegateMethodsSubtopic.h"
#import "AKInstanceMethodsSubtopic.h"
#import "AKNotificationsSubtopic.h"
#import "AKPropertiesSubtopic.h"
#import "AKSortUtils.h"

@implementation AKClassTopic

#pragma mark -
#pragma mark Factory methods

+ (id)topicWithClassNode:(AKClassNode *)classNode
{
    return [[[self alloc] initWithClassNode:classNode] autorelease];
}

#pragma mark -
#pragma mark Init/awake/dealloc

- (id)initWithClassNode:(AKClassNode *)classNode
{
    if ((self = [super init]))
    {
        _classNode = [classNode retain];
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
    [_classNode release];

    [super dealloc];
}

#pragma mark -
#pragma mark AKTopic methods

- (AKClassNode *)parentClassOfTopic
{
    return [_classNode parentClass];
}

- (NSString *)stringToDisplayInTopicBrowser
{
    return [_classNode nodeName];
}

- (NSString *)stringToDisplayInDescriptionField
{
    return [NSString stringWithFormat:@"%@ class %@",
            [_classNode nameOfOwningFramework], [_classNode nodeName]];
}

- (NSString *)pathInTopicBrowser
{
    if (_classNode == nil)
    {
        return nil;
    }

    NSString *path = [AKTopicBrowserPathSeparator stringByAppendingString:[_classNode nodeName]];
    AKClassNode *superNode = _classNode;

    while ((superNode = [superNode parentClass]))
    {
        path = [AKTopicBrowserPathSeparator stringByAppendingString:
                [[superNode nodeName] stringByAppendingString:path]];
    }

    return path;
}

- (BOOL)browserCellHasChildren
{
    return [_classNode hasChildClasses];
}

- (NSArray *)childTopics
{
    NSMutableArray *columnValues = [NSMutableArray array];

    for (AKClassNode *subclassNode in [AKSortUtils arrayBySortingArray:[_classNode childClasses]])
    {
        [columnValues addObject:[AKClassTopic topicWithClassNode:subclassNode]];
    }

    return columnValues;
}

#pragma mark -
#pragma mark AKBehaviorTopic methods

- (NSString *)behaviorName
{
    return [_classNode nodeName];
}

- (AKDatabaseNode *)topicNode
{
    return _classNode;
}

- (void)populateSubtopicsArray:(NSMutableArray *)array
{
    [array setArray:(@[
                     [AKClassGeneralSubtopic subtopicForClassNode:_classNode],
                     [AKPropertiesSubtopic subtopicForBehaviorNode:_classNode includeAncestors:NO],
                     [AKPropertiesSubtopic subtopicForBehaviorNode:_classNode includeAncestors:YES],
                     [AKClassMethodsSubtopic subtopicForBehaviorNode:_classNode includeAncestors:NO],
                     [AKClassMethodsSubtopic subtopicForBehaviorNode:_classNode includeAncestors:YES],
                     [AKInstanceMethodsSubtopic subtopicForBehaviorNode:_classNode includeAncestors:NO],
                     [AKInstanceMethodsSubtopic subtopicForBehaviorNode:_classNode includeAncestors:YES],
                     [AKDelegateMethodsSubtopic subtopicForClassNode:_classNode includeAncestors:NO],
                     [AKDelegateMethodsSubtopic subtopicForClassNode:_classNode includeAncestors:YES],
                     [AKNotificationsSubtopic subtopicForClassNode:_classNode includeAncestors:NO],
                     [AKNotificationsSubtopic subtopicForClassNode:_classNode includeAncestors:YES],
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

    NSString *className = [prefDict objectForKey:AKBehaviorNamePrefKey];

    if (className == nil)
    {
        DIGSLogWarning(@"malformed pref dictionary for class %@", [self className]);
        return nil;
    }
    else
    {
        AKDatabase *db = [[NSApp delegate] appDatabase];
        AKClassNode *classNode = [db classWithName:className];

        if (!classNode)
        {
            DIGSLogInfo(@"couldn't find a class in the database named %@", className);
            return nil;
        }

        return [self topicWithClassNode:classNode];
    }
}

@end
