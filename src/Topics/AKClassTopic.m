/*
 * AKClassTopic.m
 *
 * Created by Andy Lee on Sun May 25 2003.
 * Copyright (c) 2003, 2004 Andy Lee. All rights reserved.
 */

#import "AKClassTopic.h"

#import "DIGSLog.h"

#import "AKSortUtils.h"
#import "AKDatabase.h"
#import "AKClassNode.h"

#import "AKAppController.h"
#import "AKClassOverviewSubtopic.h"
#import "AKPropertiesSubtopic.h"
#import "AKClassMethodsSubtopic.h"
#import "AKInstanceMethodsSubtopic.h"
#import "AKDelegateMethodsSubtopic.h"
#import "AKNotificationsSubtopic.h"

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

+ (AKTopic *)fromPrefDictionary:(NSDictionary *)prefDict
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

- (NSArray *)createSubtopicsArray
{
    AKClassOverviewSubtopic *overviewSubtopic;
    overviewSubtopic = [AKClassOverviewSubtopic subtopicForClassNode:_classNode];

    AKPropertiesSubtopic *propertiesSubtopic;
    propertiesSubtopic = [AKPropertiesSubtopic subtopicForBehaviorNode:_classNode
                                                      includeAncestors:NO];
    AKPropertiesSubtopic *allPropertiesSubtopic;
    allPropertiesSubtopic = [AKPropertiesSubtopic subtopicForBehaviorNode:_classNode
                                                         includeAncestors:YES];
    AKClassMethodsSubtopic *classMethodsSubtopic;
    classMethodsSubtopic = [AKClassMethodsSubtopic subtopicForBehaviorNode:_classNode
                                                          includeAncestors:NO];
    AKClassMethodsSubtopic *allClassMethodsSubtopic;
    allClassMethodsSubtopic = [AKClassMethodsSubtopic subtopicForBehaviorNode:_classNode
                                                             includeAncestors:YES];
    AKInstanceMethodsSubtopic *instMethodsSubtopic;
    instMethodsSubtopic = [AKInstanceMethodsSubtopic subtopicForBehaviorNode:_classNode
                                                            includeAncestors:NO];
    AKInstanceMethodsSubtopic *allInstanceMethodsSubtopic;
    allInstanceMethodsSubtopic = [AKInstanceMethodsSubtopic subtopicForBehaviorNode:_classNode
                                                                   includeAncestors:YES];
    AKDelegateMethodsSubtopic *delegateMethodsSubtopic;
    delegateMethodsSubtopic = [AKDelegateMethodsSubtopic subtopicForClassNode:_classNode
                                                             includeAncestors:NO];
    AKDelegateMethodsSubtopic *allDelegateMethodsSubtopic;
    allDelegateMethodsSubtopic = [AKDelegateMethodsSubtopic subtopicForClassNode:_classNode
                                                                includeAncestors:YES];
    AKNotificationsSubtopic *notificationsSubtopic;
    notificationsSubtopic = [AKNotificationsSubtopic subtopicForClassNode:_classNode
                                                         includeAncestors:NO];
    AKNotificationsSubtopic *allNotificationsSubtopic;
    allNotificationsSubtopic = [AKNotificationsSubtopic subtopicForClassNode:_classNode
                                                            includeAncestors:YES];
    return (@[
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
            ]);
}

@end
