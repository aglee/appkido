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

//-------------------------------------------------------------------------
// Factory methods
//-------------------------------------------------------------------------

+ (id)topicWithClassNode:(AKClassNode *)classNode
{
    return [[[self alloc] initWithClassNode:classNode] autorelease];
}

//-------------------------------------------------------------------------
// Init/awake/dealloc
//-------------------------------------------------------------------------

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
    [self release];
    return nil;
}

- (void)dealloc
{
    [_classNode release];

    [super dealloc];
}

//-------------------------------------------------------------------------
// AKTopic methods
//-------------------------------------------------------------------------

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
    return
        [NSString stringWithFormat:@"%@ class %@",
            [[_classNode owningFramework] frameworkName], [_classNode nodeName]];
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
        path =
            [AKTopicBrowserPathSeparator stringByAppendingString:
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
    NSEnumerator *en = [[AKSortUtils arrayBySortingArray:[_classNode childClasses]] objectEnumerator];
    AKClassNode *subclassNode;

    while ((subclassNode = [en nextObject]))
    {
        [columnValues addObject:[AKClassTopic topicWithClassNode:subclassNode]];
    }

    return columnValues;
}

//-------------------------------------------------------------------------
// AKBehaviorTopic methods
//-------------------------------------------------------------------------

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
    AKClassOverviewSubtopic *overviewSubtopic =
        [AKClassOverviewSubtopic subtopicForClassNode:_classNode];

    AKPropertiesSubtopic *propertiesSubtopic =
        [AKPropertiesSubtopic
            subtopicForBehaviorNode:_classNode
            includeAncestors:NO];
    AKPropertiesSubtopic *allPropertiesSubtopic =
        [AKPropertiesSubtopic
            subtopicForBehaviorNode:_classNode
            includeAncestors:YES];

    AKClassMethodsSubtopic *classMethodsSubtopic =
        [AKClassMethodsSubtopic
            subtopicForBehaviorNode:_classNode
            includeAncestors:NO];
    AKClassMethodsSubtopic *allClassMethodsSubtopic =
        [AKClassMethodsSubtopic
            subtopicForBehaviorNode:_classNode
            includeAncestors:YES];

    AKInstanceMethodsSubtopic *instMethodsSubtopic =
        [AKInstanceMethodsSubtopic
            subtopicForBehaviorNode:_classNode
            includeAncestors:NO];
    AKInstanceMethodsSubtopic *allInstanceMethodsSubtopic =
        [AKInstanceMethodsSubtopic
            subtopicForBehaviorNode:_classNode
            includeAncestors:YES];

    AKDelegateMethodsSubtopic *delegateMethodsSubtopic =
        [AKDelegateMethodsSubtopic
            subtopicForClassNode:_classNode
            includeAncestors:NO];
    AKDelegateMethodsSubtopic *allDelegateMethodsSubtopic =
        [AKDelegateMethodsSubtopic
            subtopicForClassNode:_classNode
            includeAncestors:YES];

    AKNotificationsSubtopic *notificationsSubtopic =
        [AKNotificationsSubtopic
            subtopicForClassNode:_classNode
            includeAncestors:NO];
    AKNotificationsSubtopic *allNotificationsSubtopic =
        [AKNotificationsSubtopic
            subtopicForClassNode:_classNode
            includeAncestors:YES];

    return
        [NSArray arrayWithObjects:
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
            nil];
}

@end
